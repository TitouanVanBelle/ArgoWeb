import FluentPostgreSQL
import Vapor

/// A single entry of a Package list.
final class Package: PostgreSQLModel
{
    var id: Int?
    var name: String
    var tag: String
    var description: String
    var readyForProcessing: Bool?

    init(id: Int? = nil, name: String, tag: String, description: String, readyForProcessing: Bool = false)
    {
        self.id = id
        self.name = name
        self.tag = tag
        self.description = description
        self.readyForProcessing = readyForProcessing
    }
}

extension Package
{
    var translationsLists: Children<Package, TranslationsList> {
        return children(\.packageId)
    }
}

/// Allows `Package` to be used as a dynamic migration.
extension Package: Migration { }

/// Allows `Package` to be encoded to and decoded from HTTP messages.
extension Package: Content { }

/// Allows `Package` to be used as a dynamic parameter in route definitions.
extension Package: Parameter { }

extension Package
{
    struct AddTag: PostgreSQLMigration
    {
        static func prepare(on conn: PostgreSQLConnection) -> Future<Void>
        {
            return PostgreSQLDatabase.update(Package.self, on: conn) { builder in
                let defaultValueConstraint = PostgreSQLColumnConstraint.default(.literal(""))
                builder.field(for: \.tag, type: .text, defaultValueConstraint)
            }
        }

        static func revert(on conn: PostgreSQLConnection) -> Future<Void>
        {
            return PostgreSQLDatabase.update(Package.self, on: conn) { builder in
                builder.deleteField(for: \.tag)
            }
        }
    }

    struct AddDescription: PostgreSQLMigration
    {
        static func prepare(on conn: PostgreSQLConnection) -> Future<Void>
        {
            return PostgreSQLDatabase.update(Package.self, on: conn) { builder in
                let defaultValueConstraint = PostgreSQLColumnConstraint.default(.literal(""))
                builder.field(for: \.description, type: .text, defaultValueConstraint)
            }
        }

        static func revert(on conn: PostgreSQLConnection) -> Future<Void>
        {
            return PostgreSQLDatabase.update(Package.self, on: conn) { builder in
                builder.deleteField(for: \.description)
            }
        }
    }
}
