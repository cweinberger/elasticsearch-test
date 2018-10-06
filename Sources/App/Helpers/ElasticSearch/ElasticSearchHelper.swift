import Vapor

internal final class ElasticSearchHelper {

    static func indexWithIndexName(_ indexName: String, env: Environment) -> String {
        return "\(env.name)_\(indexName)"
    }
}
