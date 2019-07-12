import FluentPostgreSQL
import Vapor

/// A single entry of a Theme list.
final class Theme: PostgreSQLModel
{
    var id: Int?
    var name: String
    var numberOfCards: Int
    var words: [String]?

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

    init(id: Int? = nil, name: String, numberOfCards: Int, words: [String]? = nil)
    {
        self.id = id
        self.name = name
        self.numberOfCards = numberOfCards
        self.words = words
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
