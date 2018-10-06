import Elasticsearch

enum ClientNormalizer: String {

    case lowerCase = "lowercase_normalizer"

    func get() -> Normalizer {

        switch(self) {
        case .lowerCase:
            return CustomNormalizer(
                name: self.rawValue,
                filter: [LowercaseFilter().name])
        }
    }
}
