import Fluent
import Vapor
import Elasticsearch

internal final class ElasticSearchSynchronizer {

    // MARK: - Prepare the index

    /// Prepares the index in elastic search:
    ///
    /// **NOTE:** the given index will be prefixed with environment name (i.e. staging_products)
    ///
    /// - Deletes the index if it exists
    /// - Creates the index and
    /// - adds properties, mappings and analyzers/normalizers/tokenizers
    @discardableResult
    func prepare(indexName: String, using container: Container) throws -> Future<Void> {

        return container.withNewConnection(to: .elasticsearch) { client in

            return try self.deleteIndex(indexName, using: client)
                .flatMap {
                    return try self.createIndex(indexName, using: client)
                }
        }
    }

    // MARK: (Private)

    @discardableResult
    private func deleteIndex(
        _ indexName: String,
        using client: ElasticsearchClient
    ) throws -> Future<Void> {

        return try client.deleteIndex(name: indexName)
            .catchMap { error in
                // TODO: Report to Bugsnag
                // Note: also throws if index was not found.
                print("Error: deleteIndex '\(indexName)': \(error)")
            }
    }

    @discardableResult
    private func createIndex(
        _ indexName: String,
        using client: ElasticsearchClient
    ) throws -> Future<Void> {

        return try ProductIndex.createIndex(indexName, on: client)
    }

    // MARK: - Import Products

    /// Imports all products into our Elastic search index
    @discardableResult
    func importAllProducts(
        using container: Container
    ) throws -> Future<Void> {

        let promise = container.eventLoop.newPromise(Void.self)
        let group = DispatchGroup()
        group.enter()
        group.notify(queue: DispatchQueue.global(), execute: { promise.succeed() })
        return container.future()
    }

    /// Imports `products` into Elastic search
    @discardableResult
    func importProducts(
        _ products: [Product],
        using container: Container,
        overwriteExisting: Bool = true
    ) throws -> Future<Void> {

        guard products.count > 0 else {
            return container.future()
        }

        return container.withNewConnection(to: .elasticsearch) { conn in

            let bulk = conn.bulkOperation()
            bulk.defaultHeader.index = ElasticSearchHelper
                .indexWithIndexName(ProductDocument.indexName,
                                    env: container.environment)

            return products
                .map({ (product: Product) -> Future<ProductDocument> in
                    return ProductDocument.make(withProduct: product, using: container)
                })
                .flatten(on: container)
                .flatMap(to: BulkResponse.self, { productDocs in

                    try productDocs.forEach { productDoc in
                        if overwriteExisting {
                            try bulk.index(
                                doc: productDoc,
                                id: String(productDoc.externalId)
                            )
                        } else {
                            try bulk.create(
                                doc: productDoc,
                                id: String(productDoc.externalId)
                            )
                        }
                    }
                    return try bulk.send()
                })
                .transform(to: ())
        }
    }
}
