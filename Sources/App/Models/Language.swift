import FluentPostgreSQL
import Vapor

/// A single entry of a Language list.
final class Language: PostgreSQLModel
{
    var id: Int?
    var name: String
    var code: String

    init(id: Int? = nil, name: String, code: String)
    {
        self.id = id
        self.name = name
        self.code = code
    }
}

extension Language
{
    var translationsLists: Children<Language, TranslationsList> {
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
        "English": "en",
        "German": "de",
        "French": "fr",
        "Spanish": "es",
        "Italian": "it"
    ]

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
    {
        // Insert all forms from formNames
        let futures = languages.map { (name, code) in
            return Language(name: name, code: code).create(on: connection).map(to: Void.self) { _ in
                return
            }
        }

        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void>
    {
        let futures = languages.map { (name, code) in
            return Language.query(on: connection).filter(\.name == name).delete()
        }

        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }
}
