import Vapor

struct PackageIndexContext: Encodable
{
    let packages: [PackageView]
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
    let readyForProcessing: Bool
    let languagesAndTranslations: [LanguageWithTranslations]
}

struct PackageUpdateForm: Content
{
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
