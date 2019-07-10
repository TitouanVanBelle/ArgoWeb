import FluentMySQL
import Vapor

/// A single entry of a Language list.
final class Language: MySQLModel
{
    var id: Int?
    var name: String

    init(id: Int? = nil, title: String)
    {
        self.id = id
        self.name = title
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
