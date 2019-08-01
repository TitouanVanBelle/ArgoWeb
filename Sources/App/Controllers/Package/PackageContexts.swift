import Vapor

struct PackageIndexContext: Encodable
{
    let packages: [Future<PackageView>]
    let currentPath: String
    let user: User
}

struct PackageNewContext: Encodable
{
    let currentPath: String
    let user: User
}

struct LanguageWithTranslations: Encodable
{
    let language: Language
    let translations: [String]
}

struct PackageShowContext: Encodable
{
    let currentPath: String
    let user: User
    let packageId: Int
    let packageName: String
    let packageTag: String
    let packageDescription: String
    let readyForProcessing: Bool
    let languagesAndTranslations: [LanguageWithTranslations]
    let yandexApiKey: String
}

struct PackageUpdateForm: Content
{
    let name: String
    let tag: String
    let description: String
    let translations: [String:[String]]
    let save_and_finish: String?
    let save: String?
    let unlock: String?
}

struct PackageView: Encodable
{
    let id: Int
    let name: String
    let numberOfCards: Int
}
