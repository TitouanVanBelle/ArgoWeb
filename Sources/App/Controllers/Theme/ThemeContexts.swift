import Vapor

struct ThemeIndexContext: Encodable
{
    let themes: [ThemeView]
    let currentPath: String
    let user: User
}

struct ThemeNewContext: Encodable
{
    let currentPath: String
    let user: User
}

struct ThemeShowContext: Encodable
{
    let id: Int
    let name: String
    let currentPath: String
    let readyForPackaging: Bool
    let words: [String]
    let user: User
}

struct ThemeUpdateForm: Content
{
    let words: [String]
    let save_and_finish: String?
    let save: String?
}

struct ThemeView: Encodable
{
    let id: Int
    let name: String
    let numberOfCards: Int
}
