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

struct Word: Encodable
{
    let value: String
    let languageId: Int
}

struct PackageShowContext: Encodable
{
    let currentPath: String
    let user: User
    let packageId: Int
    let packageName: String
    let readyForProcessing: Bool
    let wordLists: [[Word]]
    let languages: [Language]
}

struct PackageUpdateForm: Content
{
    let words: [String]
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
