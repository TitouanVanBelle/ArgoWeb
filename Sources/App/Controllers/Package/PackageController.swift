import Vapor
import FluentPostgreSQL

final class PackageController
{
    func index(_ req: Request) throws -> Future<View>
    {
        return Package.query(on: req).sort(\.name).all().flatMap { packages in
            let packagesList = try packages.compactMap { package in
                return try package.translationsLists.query(on: req).first().map { translationList in
                    return PackageView(
                        id: package.id!,
                        name: package.name,
                        numberOfCards: translationList?.translations?.count ?? 0
                    )
                }
            }

            let user = try req.requireAuthenticated(User.self)
            let context = PackageIndexContext(
                packages: packagesList,
                currentPath: req.http.url.path,
                user: user
            )

            return try req.view().render("Packages/index", context)
        }
    }

    func new(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)

        let context = PackageNewContext(
            currentPath: req.http.url.path,
            user: user
        )
        return try req.view().render("Packages/new", context)
    }

    func create(_ req: Request) throws -> Future<Response>
    {
        return try req.content.decode(Package.self).flatMap { package in
            return package.save(on: req).map { _ in
                return req.redirect(to: "/packages/\(package.id!)")
            }
        }
    }

    func show(_ req: Request) throws -> Future<View>
    {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Package.self).flatMap { package in
            return Language.query(on: req).all().flatMap { languages in
                return try package.translationsLists.query(on: req).all().flatMap { translationsLists in

                    var languagesAndTranslations = [LanguageWithTranslations]()
                    var numberOfEmptyWords = 1
                    
                    if translationsLists.count > 0 {
                        numberOfEmptyWords = translationsLists.first!.translations!.count
                    }
                    
                    languagesAndTranslations = languages.map { language in
                        if let languageTranslationList = translationsLists.filter({ $0.languageId == language.id }).first {
                            return LanguageWithTranslations(
                                language: language,
                                translations: languageTranslationList.translations!
                            )
                        } else {
                            let emptyTranslations = Array(repeating: "", count: numberOfEmptyWords)
                            return LanguageWithTranslations(language: language, translations: emptyTranslations)
                        }
                    }
                    
                    let context = PackageShowContext(
                        currentPath: req.http.url.path,
                        user: user,
                        packageId: package.id!,
                        packageName: package.name,
                        readyForProcessing: package.readyForProcessing ?? false,
                        languagesAndTranslations: languagesAndTranslations
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
                let redirect = "/packages/\(package.id!)"
                
                if let _ = packageUpdateForm.save_and_finish {
                    package.readyForProcessing = true
                } else if let _ = packageUpdateForm.unlock {
                    package.readyForProcessing = false
                }
                
                package.save(on: req)
                
                return packageUpdateForm.translations.keys.map { languageIdString in
                    let languageId = Int(languageIdString)!
                    return TranslationsList.query(on: req).filter(\.languageId == languageId).filter(\.packageId == package.id!).first().map { translationList in
                        var translationListToSave: TranslationsList!
                        let translations = packageUpdateForm.translations[languageIdString]
                        if let translationList = translationList {
                            translationList.translations = translations
                            translationListToSave = translationList
                        } else {
                            let newTranslationList = TranslationsList(
                                packageId: package.id!,
                                languageId: languageId,
                                translations: translations
                            )
                            translationListToSave = newTranslationList
                        }
                        
                        translationListToSave.save(on: req)
                    }
                }.flatten(on: req).map { _ in
                    req.redirect(to: redirect)
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
}

extension PackageController
{
    struct API
    {
        struct APIPackage: Content
        {
            let id: Int
            let name: String
            let languageCode: String
            let languageName: String
            let translations: [String]
        }
        
        func packagesReadyForProcessing(_ req: Request) throws -> Future<[APIPackage]>
        {
            return req.withPooledConnection(to: .psql) { conn in
                return conn.raw("""
                SELECT "Package".id, "Package".name, "TranslationsList".translations, "Language".code AS "languageCode", "Language".name AS "languageName"
                FROM "Package"
                INNER JOIN "TranslationsList" ON "Package".id="TranslationsList"."packageId"
                INNER JOIN "Language" ON "TranslationsList"."languageId"="Language"."id"
                WHERE "readyForProcessing" = 'true'
                ORDER BY "packageId";
                """).all(decoding: APIPackage.self)
            }
        }
    }
}
