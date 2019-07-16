import Vapor

final class ThemeController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let themes = Theme.query(on: req).sort(\.name).all()
        let user = try req.requireAuthenticated(User.self)

        return themes.flatMap { themes in
            let themesList = themes.compactMap { theme in
                return ThemeView(
                    id: theme.id!,
                    name: theme.name,
                    numberOfCards: theme.numberOfCards
                )
            }

            let context = ThemeIndexContext(
                themes: themesList,
                currentPath: req.http.url.path,
                user: user
            )

            return try req.view().render("Themes/index", context)
        }
    }

    func new(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)

        let context = ThemeNewContext(
            currentPath: req.http.url.path,
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
                name: theme.name,
                currentPath: req.http.url.path,
                readyForPackaging: theme.readyForPackaging ?? false,
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
                if let _ = themeUpdateForm.save_and_finish {
                    let hasEmptyWords = themeUpdateForm.words.reduce(false) { $0 || $1.isEmpty }
                    if !hasEmptyWords {
                        theme.readyForPackaging = true
                    }
                }
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
