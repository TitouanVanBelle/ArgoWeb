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
    let availableNumberOfCards: [Int]
    let user: User
}

struct ThemeShowContext: Encodable
{
    let id: Int
    let currentPath: String
    let words: [String]
    let user: User
}

final class ThemeController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let themes = Theme.query(on: req).sort(\.name).all()
        let user = try req.requireAuthenticated(User.self)

        return themes.flatMap { themes in
            let context = ThemeIndexContext(
                themes: themes,
                currentPath: req.http.url.path,
                user: user
            )

            return try req.view().render("Themes/index", context)
        }
    }

    func new(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)
        let availableNumberOfCards = Array(5...50)

        let context = ThemeNewContext(
            currentPath: req.http.url.path,
            availableNumberOfCards: availableNumberOfCards,
            user: user
        )
        return try req.view().render("Themes/new", context)
    }

    func create(_ req: Request) throws -> Future<Response>
    {
        return try req.content.decode(Theme.self).flatMap { theme in
            return theme.save(on: req).map { _ in
                return req.redirect(to: "/themes/\(theme.id!)")
            }
        }
    }

    func show(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Theme.self).flatMap { theme in
            let words = theme.words ?? Array(repeating: "", count: theme.numberOfCards)
            let context = ThemeShowContext(
                id: theme.id!,
                currentPath: req.http.url.path,
                words: words,
                user: user
            )
            return try req.view().render("Themes/show", context)
        }
    }

    func update(_ req: Request) throws -> Future<Response>
    {
        return try req.parameters.next(Theme.self).flatMap { theme in
            return try req.content.decode(ThemeUpdateForm.self).flatMap { themeUpdateForm in
                theme.words = themeUpdateForm.words
                return theme.save(on: req).map { _ in
                    return req.redirect(to: "/themes")
                }
            }
        }
    }

    func delete(_ req: Request) throws -> Future<Response>
    {
        return try req.parameters.next(Theme.self).flatMap { theme in
            return theme.delete(on: req).map { _ in
                return req.redirect(to: "/themes")
            }
        }
    }
}

struct ThemeUpdateForm: Content
{
    let words: [String]
}
