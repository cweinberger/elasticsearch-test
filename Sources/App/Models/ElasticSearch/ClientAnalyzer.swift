import Elasticsearch

enum ClientAnalyzer: String {

    case clientAnalyzer = "client_analyzer"

    func get() -> Analyzer {

        switch(self) {
        case .clientAnalyzer:
            return CustomAnalyzer(
                name: self.rawValue,
                tokenizer: StandardTokenizer(),
                filter: [
                    ClientFilter.lowerCase.get(),
                    ClientFilter.stemmer.get(),
                    ClientFilter.synonym.get()
                ]
            )
        }
    }
}

enum ClientTokenizer: String {

    case client


}
