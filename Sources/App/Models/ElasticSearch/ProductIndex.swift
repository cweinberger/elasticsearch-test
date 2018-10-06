import Vapor
import Elasticsearch

internal struct ProductIndex {

    enum Keys: String {
        case id, externalId, name, description, categories, subcategories, productGroups, attributes
    }

    struct Boost {
        static let matchNameFully: Decimal = 80
        static let matchNamePartially: Decimal = 100
        static let matchDescription: Decimal = 1
        static let matchProductGroups: Decimal = 300
        static let matchSubcategories: Decimal = 1
        static let matchCategories: Decimal = 1
        static let matchNameEdge: Decimal = 95
        static let matchAttributes: Decimal = 80
    }

    static let indexName = "products"
    static let docTypeName = "_doc"

    static func makeIndex(
        _ indexName: String = ProductIndex.indexName,
        docTypeName: String = ProductIndex.docTypeName,
        on client: ElasticsearchClient
    ) throws -> ElasticsearchIndex {

        let idx = client.configureIndex(name: indexName)
            .indexSettings(IndexSettings(shards: 5, replicas: 1))
            .property(key: Keys.id.rawValue, type: MapKeyword())
            .property(key: Keys.externalId.rawValue, type: MapKeyword())
            .property(key: Keys.name.rawValue, type: self.fuzzyProperties())
            .property(key: Keys.description.rawValue, type: MapText())
            .property(key: Keys.categories.rawValue, type: MapText())
            .property(key: Keys.subcategories.rawValue, type: MapText())
            .property(key: Keys.productGroups.rawValue, type: MapText())
            .property(key: Keys.attributes.rawValue, type: self.fuzzyProperties())

        return idx
    }

    static func createIndex(
        _ indexName: String = ProductIndex.indexName,
        docTypeName: String = ProductIndex.docTypeName,
        on client: ElasticsearchClient
    ) throws -> Future<Void> {

        let index = try makeIndex(
            indexName,
            docTypeName: docTypeName,
            on: client
        )
        return try index.create()
    }

    private static func fuzzyProperties() -> Mappable {

        let fields = [
            "raw": TextField(type: .keyword, normalizer: ClientNormalizer.lowerCase.get()),
            "fuzzy": TextField(type: .text, analyzer: ClientAnalyzer.clientAnalyzer.get())
        ]

        return MapKeyword(fields: fields)
    }

    static func searchProducts(
        with query: String,
        on client: ElasticsearchClient
    ) throws -> Future<[ProductDocument]> {

        let query = Query(

            BoolQuery(should: [

                    Term(field: "\(Keys.name.rawValue).raw", value: query, boost: Boost.matchNameFully),
                    MatchPhrase(field: "\(Keys.name.rawValue).fuzzy", query: query, boost: Boost.matchNamePartially),
                    MatchPhrasePrefix(field: Keys.name.rawValue, query: query, boost: Boost.matchNameEdge),
                    Match(field: Keys.description.rawValue, value: query, boost: Boost.matchDescription),
                    Match(field: Keys.categories.rawValue, value: query, boost: Boost.matchCategories),
                    Match(field: Keys.subcategories.rawValue, value: query, boost: Boost.matchSubcategories),
                    Match(field: Keys.productGroups.rawValue, value: query, boost: Boost.matchProductGroups),
                    Match(field: "\(Keys.attributes.rawValue).fuzzy", value: query, boost: Boost.matchAttributes),

                ], minimumShouldMatch: 1)
        )

        let indexName = ElasticSearchHelper.indexWithIndexName(ProductDocument.indexName, env: .development)

        let results = try client.search(
            decodeTo: ProductDocument.self,
            index: indexName,
            query: SearchContainer(query)
        )
        return results.map(to: [ProductDocument].self) { searchResponse in
            guard let hits = searchResponse.hits else { return [] }
            let productDocuments = hits.hits.map { $0.source }
            return productDocuments
        }
    }
}
