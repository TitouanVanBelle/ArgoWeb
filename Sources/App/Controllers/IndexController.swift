import Vapor
import FluentPostgreSQL

struct IndexContext: Encodable
{
    let currentPath: String
    let languagesCount: Future<Int>
    let packagesCount: Future<Int>
    let themesCount: Future<Int>
    let user: User
}

final class IndexController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)

        var query = Package.query(on: req)

        if let isAdmin = user.admin, !isAdmin {
            query = query.filter(\.languageId == user.languageId)
        }

        let packagesCount = query.count()

        let context = IndexContext(
            currentPath: req.http.url.path,
            languagesCount: Language.query(on: req).count(),
            packagesCount: packagesCount,
            themesCount: Theme.query(on: req).count(),
            user: user
        )

        return try req.view().render("index", context)
    }
}
