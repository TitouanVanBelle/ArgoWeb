import Vapor
import FluentPostgreSQL

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
