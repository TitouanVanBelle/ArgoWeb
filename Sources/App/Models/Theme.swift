import FluentPostgreSQL
import Vapor

/// A single entry of a Theme list.
final class Theme: PostgreSQLModel
{
    var id: Int?
    var name: String
    var words: [String]?
    var readyForPackaging: Bool?

    var numberOfCards: Int {
        return words?.count ?? 0
    }

    var isValid: Bool {
        guard let words = words else {
            return false
        }

        for word in words {
            if word.isEmpty {
                return false
            }
        }

        return true
    }

    init(id: Int? = nil, name: String, words: [String]? = nil, readyForPackaging: Bool = false)
    {
        self.id = id
        self.name = name
        self.words = words
        self.readyForPackaging = readyForPackaging
    }
}

extension Theme
{
    var packages: Children<Theme, Package> {
        return children(\.themeId)
    }
}

/// Allows `Theme` to be used as a dynamic migration.
extension Theme: Migration { }

/// Allows `Theme` to be encoded to and decoded from HTTP messages.
extension Theme: Content { }

/// Allows `Theme` to be used as a dynamic parameter in route definitions.
extension Theme: Parameter { }

struct ThemeReadyForPackagingMigration: PostgreSQLMigration
{
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void>
    {
        return PostgreSQLDatabase.update(Theme.self, on: conn) { builder in
            builder.field(for: \.readyForPackaging, type: .bool)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> Future<Void>
    {
        return PostgreSQLDatabase.update(Theme.self, on: conn) { builder in
            builder.deleteField(for: \.readyForPackaging)
        }
    }
}
