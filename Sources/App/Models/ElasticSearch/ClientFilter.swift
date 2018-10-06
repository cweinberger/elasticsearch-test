import Elasticsearch

enum ClientFilter: String {

    case lowerCase = "lowercase_filter"
    case stemmer = "stemmer_filter"
    case synonym = "synonym_filter"

    func get() -> TokenFilter {

        switch(self) {
        case .lowerCase:
            return LowercaseFilter()

        case .stemmer:
            return StemmerFilter(language: StemmerFilter.Language.danish)

        case .synonym:
            return SynonymFilter(
                name: self.rawValue,
                synonyms: ["brænde, briketter, træbriketter, pejsebrænde, brændetårn, pejsetårn",
                           "grill, gasgrill, kuglegrill, kulgrill",
                           "skruemaskine, boremaskine, akkuskruemaskine, boremaskiner",
                           "sko, træsko, sikkerhedssko, tøffel, overtrækssko, vandresko"]
            )
        }
    }
}
