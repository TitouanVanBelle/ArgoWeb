import Vapor

final class PackageController
{
    func index(_ req: Request) throws -> Future<View>
    {
        let packages = Package.query(on: req).sort(\.name).all()
        let user = try req.requireAuthenticated(User.self)

        return packages.flatMap { packages in
            let packagesList = packages.compactMap { package in
                return PackageView(
                    id: package.id!,
                    name: package.name,
                    numberOfCards: 0//package.numberOfCards
                )
            }

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
                    var wordLists = [[Word]]()
                    
                    if translationsLists.isEmpty {
                        wordLists = [languages.map { language in
                            return Word(value: "", languageId: language.id!)
                        }]
                    } else {
                        for translationsList in translationsLists {
                            for (index, translation) in translationsList.translations!.enumerated() {
                                let word = Word(value: translation, languageId: translationsList.languageId)
                                wordLists[index].append(word)
                            }
                        }
                    }
                    
                    let context = PackageShowContext(
                        currentPath: req.http.url.path,
                        user: user,
                        packageId: package.id!,
                        packageName: package.name,
                        readyForProcessing: package.readyForProcessing ?? false,
                        wordLists: wordLists,
                        languages: languages
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
                var redirect = "/packages"
                if let _ =  packageUpdateForm.unlock {
                    package.readyForProcessing = false
                    redirect = "/packages/\(package.id!)"
                } else {
                    if let _ = packageUpdateForm.save_and_finish {
                        let hasEmptyWords = packageUpdateForm.words.reduce(false) { $0 || $1.isEmpty }
                        if !hasEmptyWords {
                            package.readyForProcessing = true
                        }
                    }
                    package.words = packageUpdateForm.words
                }

                return package.save(on: req).map { _ in
                    return req.redirect(to: redirect)
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
