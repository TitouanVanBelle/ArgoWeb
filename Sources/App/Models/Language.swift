import FluentPostgreSQL
import Vapor

/// A single entry of a Language list.
final class Language: PostgreSQLModel
{
    var id: Int?
    var name: String

    init(id: Int? = nil, name: String)
    {
        self.id = id
        self.name = name
    }
}

extension Language
{
    var packages: Children<Language, Package> {
        return children(\.languageId)
    }
}

/// Allows `Language` to be used as a dynamic migration.
extension Language: Migration { }

/// Allows `Language` to be encoded to and decoded from HTTP messages.
extension Language: Content { }

/// Allows `Language` to be used as a dynamic parameter in route definitions.
extension Language: Parameter { }

struct CreateLanguages: PostgreSQLMigration
{
    static let languages = [
        "English",
        "German",
        "French",
        "Spanish",
        "Italian"
    ]

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
    {
        // Insert all forms from formNames
        let futures = languages.map { name in
            return Language(name: name).create(on: connection).map(to: Void.self) { _ in
                return
            }
        }

        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void>
    {
        let futures = languages.map { name in
            return Language.query(on: connection).filter(\.name == name).delete()
        }

        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }
}
