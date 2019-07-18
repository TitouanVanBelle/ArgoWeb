import Vapor

struct PackageIndexContext: Encodable
{
    let packages: [Future<PackageView>]
    let languages: Future<[Language]>
    let themes: Future<[Theme]>
    let selectedLanguage: Int?
    let selectedTheme: Int?
    let currentPath: String
    let user: User
}

struct PackageNewContext: Encodable
{
    let languages: Future<[Language]>
    let themes: Future<[Theme]>
    let currentPath: String
    let user: User
}

struct PackageShowContext: Encodable
{
    let id: Int
    let currentPath: String
    let theme: String
    let numberOfCards: Int
    let translations: [Translation]
    let readyForProcessing: Bool
    let user: User
}

struct PackageUpdateForm: Content
{
    let translations: [String]
    let save_and_finish: String?
    let save: String?
}

struct PackageView: Encodable
{
    let id: Int?
    let theme: String
    let language: String
    let processed: Bool
    let readyForProcessing: Bool
}

struct Translation: Encodable
{
    let word: String
    let translation: String
    let link: String
}
