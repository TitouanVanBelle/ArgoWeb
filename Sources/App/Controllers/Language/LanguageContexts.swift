import Vapor

struct LanguageIndexContext: Encodable
{
    let languages: [Language]
    let currentPath: String
    let user: User
}

struct LanguageNewContext: Encodable
{
    let currentPath: String
}

struct LanguageShowContext: Encodable
{
    let currentPath: String
}
