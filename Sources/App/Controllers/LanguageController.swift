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

final class LanguageController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let languages = Language.query(on: req).sort(\.name).all()
        let user = try req.requireAuthenticated(User.self)

        return languages.flatMap { languages in
            let context = LanguageIndexContext(
                languages: languages,
                currentPath: req.http.url.path,
                user: user
            )
            
            return try req.view().render("Languages/index", context)
        }
    }

    func new(_ req: Request) throws -> Future<View>
    {
        let context = LanguageNewContext(currentPath: req.http.url.path)
        return try req.view().render("Languages/new", context)
    }

    func create(_ req: Request) throws -> Future<Response>
    {
        return try req.content.decode(Language.self).flatMap { language in
            return language.save(on: req).map { _ in
                return req.redirect(to: "/languages")
            }
        }
    }

    func show(_ req: Request) throws -> Future<View>
    {
        let context = LanguageShowContext(
            currentPath: req.http.url.path
        )
        return try req.view().render("Languages/show", context)
    }

    func delete(_ req: Request) throws -> Future<Response>
    {
        return try req.parameters.next(Language.self).flatMap { language in
            return language.delete(on: req).map { _ in
                return req.redirect(to: "/languages")
            }
        }
    }
}
