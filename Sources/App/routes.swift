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
    protectedRouter.get("packages", Package.parameter, use: packageController.show)
    protectedRouter.post("packages", Package.parameter, "update", use: packageController.update)
    protectedRouter.post("packages", Package.parameter, "delete", use: packageController.delete)
    protectedRouter.post("packages", "create_missing_packages", use: packageController.createMissingPackages)

    // MARK: Themes

    let themeController = ThemeController()
    protectedRouter.get("themes", use: themeController.index)
    protectedRouter.get("themes", "new", use: themeController.new)
    protectedRouter.post("themes", use: themeController.create)
    protectedRouter.post("themes", Theme.parameter, "update", use: themeController.update)
    protectedRouter.get("themes", Theme.parameter, use: themeController.show)
    protectedRouter.post("themes", Theme.parameter, "delete", use: themeController.delete)

    // MARK: API

    let packageAPIController = PackageController.API()
    let api = router.grouped("api")
    api.get("packages", use: packageAPIController.index)
    api.get("packages", Package.parameter, "process", use: packageAPIController.process)
}

struct Obj: Content {
    let name: String
}
