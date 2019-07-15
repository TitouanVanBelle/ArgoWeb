import Vapor

struct ThemeIndexContext: Encodable
{
    let themes: [Theme]
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
    let currentPath: String
    let words: [String]
    let user: User
}

struct ThemeUpdateForm: Content
{
    let words: [String]
}


