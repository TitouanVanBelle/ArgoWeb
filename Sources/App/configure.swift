import FluentMySQL
import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws
{
    // Register providers first

    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    try services.register(FluentMySQLProvider())

    // Register routes to the router

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware

    try services.register(AuthenticationProvider())

    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    var mysqlConfig: MySQLDatabaseConfig!
    if env.isRelease {
        mysqlConfig = MySQLDatabaseConfig.root(database: "argo")
    } else {
        mysqlConfig = MySQLDatabaseConfig(
            hostname: "127.0.0.1",
            port: 3306,
            username: "root",
            password: "92ppbhp.",
            database: "argo"
        )
    }
    
    services.register(mysqlConfig)

    // Configure Custom Tags

    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(NavItemTag(), as: "navItem")
        return config
    }

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Configure migrations

    var migrations = MigrationConfig()
    migrations.add(model: Flashcard.self, database: .mysql)
    migrations.add(model: Language.self, database: .mysql)
    migrations.add(model: Package.self, database: .mysql)
    migrations.add(model: Theme.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    services.register(migrations)
}
