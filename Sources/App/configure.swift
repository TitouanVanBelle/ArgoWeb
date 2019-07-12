import FluentPostgreSQL
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

    try services.register(FluentPostgreSQLProvider())

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

    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        port: 5432,
        username: "titouanvanbelle",
        database: "argo",
        password: nil,
        transport: .cleartext
    )
    let postgres = PostgreSQLDatabase(config: databaseConfig)

    // Configure Custom Tags

    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(NavItemTag(), as: "navItem")
        return config
    }

    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Configure migrations

    var migrations = MigrationConfig()
    migrations.add(model: Flashcard.self, database: .psql)
    migrations.add(model: Language.self, database: .psql)
    migrations.add(model: Package.self, database: .psql)
    migrations.add(model: Theme.self, database: .psql)
    migrations.add(model: User.self, database: .psql)

    migrations.add(migration: CreateLanguages.self, database: .psql)
    services.register(migrations)
}
