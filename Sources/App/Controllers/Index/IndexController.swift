import Vapor
import FluentPostgreSQL

final class IndexController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)

        var query = TranslationsList.query(on: req)

        if let isAdmin = user.admin, !isAdmin {
            query = query.filter(\.languageId == user.languageId)
        }

        let translationsListsCount = query.count()

        let context = IndexContext(
            currentPath: req.http.url.path,
            languagesCount: Language.query(on: req).count(),
            translationsListsCount: translationsListsCount,
            packagesCount: Package.query(on: req).count(),
            user: user,
            apiKeyA: Environment.get("yandexApiKey") ?? "NULL",
            apiKeyB: Environment.get("yandexapikey") ?? "NULL"
        )

        return try req.view().render("index", context)
    }
}
