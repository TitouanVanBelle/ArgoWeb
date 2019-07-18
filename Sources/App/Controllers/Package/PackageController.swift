import Vapor
import FluentPostgreSQL

final class PackageController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)
        var selectedTheme: Int?
        var selectedLanguage: Int?

        var query = Package.query(on: req)
        if let isAdmin = user.admin, isAdmin {
            if let filteredThemeId = req.query[Int.self, at: "theme"] {
                selectedTheme = filteredThemeId
                query = query.filter(\.themeId == filteredThemeId)
            }

            if let filteredLanguageId = req.query[Int.self, at: "language"] {
                selectedLanguage = filteredLanguageId
                query = query.filter(\.languageId == filteredLanguageId)
            }

        } else {
            query = Package.query(on: req)
                .filter(\.languageId == user.languageId)
                .filter(\.processed == false)
                .filter(\.readyForProcessing == false)
        }

        let packages = query.all()

        return packages.flatMap { packages in
            let packagesList = packages.compactMap { package in
                return package.theme.get(on: req).flatMap { theme in
                    return package.language.get(on: req).map { language in
                        return PackageView(
                            id: package.id,
                            theme: theme.name,
                            language: language.name,
                            processed: package.processed,
                            readyForProcessing: package.readyForProcessing
                        )
                    }
                }
            }

            let languages = Language.query(on: req).sort(\.name).all().map { languages in
                return languages
            }

            let themes = Theme.query(on: req).sort(\.name).all().map { themes in
                return themes
            }
            
            let context = PackageIndexContext(
                packages: packagesList,
                languages: languages,
                themes: themes,
                selectedLanguage: selectedLanguage,
                selectedTheme: selectedTheme,
                currentPath: req.http.url.path,
                user: user
            )

            return try req.view().render("Packages/index", context)
        }
    }

    func show(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Package.self).flatMap { package in
            return package.theme.get(on: req).flatMap { theme in
                return package.language.get(on: req).flatMap { language in
                    let translations = package.translations ?? Array(repeating: "", count: theme.numberOfCards)
                    let readyForProcessing = package.readyForProcessing
                    let fullTranslations = theme.words!.enumerated().map {
                        Translation(word: $1,
                                    translation:translations[$0],
                                    link: "https://www.wordreference.com/en\(language.code)/\($1)"
                        )
                    }
                    let context = PackageShowContext(
                        id: package.id!,
                        currentPath: req.http.url.path,
                        translations: fullTranslations,
                        readyForProcessing: readyForProcessing,
                        user: user
                    )

                    return try req.view().render("Packages/show", context)
                }
            }
        }
    }

    func update(_ req: Request) throws -> Future<Response>
    {
        return try req.parameters.next(Package.self).flatMap { package in
            return try req.content.decode(PackageUpdateForm.self).flatMap { packageUpdateForm in
                if let _ = packageUpdateForm.save_and_finish {
                    package.readyForProcessing = true
                }
                package.translations = packageUpdateForm.translations
                return package.save(on: req).map { _ in
                    return req.redirect(to: "/packages")
                }
            }
        }
    }

    func delete(_ req: Request) throws -> Future<Response>
    {
        return try req.parameters.next(Package.self).flatMap { package in
            return package.delete(on: req).map { _ in
                return req.redirect(to: "/packages")
            }
        }
    }

    func createMissingPackages(_ req: Request) throws -> Future<Response>
    {
        return Theme.query(on: req).filter(\.readyForPackaging == true).all().flatMap { existingThemes in
            guard existingThemes.count > 0 else {
                return Future.map(on: req) {
                    return req.redirect(to: "/packages")
                }
            }

            return Language.query(on: req).all().flatMap { existingLanguages in
                guard existingLanguages.count > 0 else {
                    return Future.map(on: req) {
                        return req.redirect(to: "/packages")
                    }
                }

                var packages = [Package]()
                for existingLanguage in existingLanguages {
                    for existingTheme in existingThemes {
                        guard existingTheme.isValid else {
                            continue
                        }

                        let themeId = existingTheme.id!
                        let languageId = existingLanguage.id!

                        let package = Package(themeId: themeId, languageId: languageId)
                        packages.append(package)
                    }
                }

                return packages.map { package in
                    return Package.query(on: req).filter(\.themeId == package.themeId).filter(\.languageId == package.languageId).first().map { existingPackage in
                        guard existingPackage == nil else {
                            return
                        }
                        package.save(on: req)
                    }
                    }.flatten(on: req).map { _ in
                    req.redirect(to: "/packages")
                }
            }
        }
    }
}

extension PackageController
{
    struct API
    {
        struct PackageWithThemeAndLanguage: Content {
            let id: Int
            let language: Language
            let theme: Theme
            let translations: [String]?
        }

        func index(_ req: Request) throws -> Future<[PackageWithThemeAndLanguage]>
        {
            return Package.query(on: req)
                .filter(\.readyForProcessing == true)
                .filter(\.processed == false)
                .join(\Theme.id, to: \Package.themeId)
                .join(\Language.id, to: \Package.languageId)
                .alsoDecode(Theme.self)
                .alsoDecode(Language.self)
                .all().map { res in
                    return res.map { packageThemeTuple, language in
                        let package = packageThemeTuple.0
                        let theme = packageThemeTuple.1
                        return PackageWithThemeAndLanguage(id: package.id!, language: language, theme: theme, translations: package.translations)
                    }
            }
        }

        func process(_ req: Request) throws -> Future<HTTPStatus>
        {
            return try req.parameters.next(Package.self).flatMap { package in
                package.processed = true
                return package.save(on: req).map { _ in
                    return HTTPStatus.ok
                }
            }
        }
    }
}
