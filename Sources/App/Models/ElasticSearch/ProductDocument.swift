import Vapor
import Fluent

public struct Product {

}

final class ProductDocument: Codable {

    static let indexName = "products"

    var id: Int?
    var externalId: Int

    init(externalId: Int) {
        self.externalId = externalId
    }

    static func make(
        withProduct: Product,
        using container: Container
    ) -> Future<ProductDocument> {

        let pd = ProductDocument(externalId: 123)
        return container.future(pd)
    }
}
