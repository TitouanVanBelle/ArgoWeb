import Vapor
import Authentication
import Crypto

public func routes(_ router: Router) throws
{
    // MARK: User

    let userController = UserController()
    router.get("register", use: userController.renderRegister)
    router.post("register", use: userController.register)
    router.get("login", use: userController.renderLogin)
    router.get("logout", use: userController.logout)


    let authSessionRouter = router.grouped(User.authSessionsMiddleware())
    authSessionRouter.post("login", use: userController.login)

    let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))

    // MARK: Index

    let indexController = IndexController()
    protectedRouter.get("/", use: indexController.index)

    // MARK: Languages

    let languageController = LanguageController()

    protectedRouter.get("languages", use: languageController.index)
    protectedRouter.get("languages", "new", use: languageController.new)
    protectedRouter.post("languages", use: languageController.create)
    protectedRouter.get("languages", Language.parameter, use: languageController.show)
    protectedRouter.post("languages", Language.parameter, "delete", use: languageController.delete)

    // MARK: Packages

    let packageController = PackageController()
    protectedRouter.get("packages", use: packageController.index)
    protectedRouter.get("packages", "new", use: packageController.new)
    protectedRouter.post("packages", use: packageController.create)
    protectedRouter.post("packages", Package.parameter, "update", use: packageController.update)
    protectedRouter.get("packages", Package.parameter, use: packageController.show)
    protectedRouter.post("packages", Package.parameter, "delete", use: packageController.delete)

    // MARK: API

//    let translationsListAPIController = TranslationsListController.API()
//    let api = router.grouped("api")
//    api.get("translationsLists", use: translationsListAPIController.index)
//    api.get("translationsLists", TranslationsList.parameter, "process", use: translationsListAPIController.process)
}

struct Obj: Content {
    let name: String
}
