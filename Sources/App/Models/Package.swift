import FluentMySQL
import Vapor

final class Package: MySQLModel
{
    var id: Int?
    var themeId: Int
    var languageId: Int
    var translations: [String]?
    var readyForProcessing: Bool
    var processed: Bool

    init(id: Int? = nil, themeId: Int, languageId: Int, translations: [String]? = nil, readyForProcessing: Bool = false, processed: Bool = false)
    {
        self.id = id
        self.themeId = themeId
        self.languageId = languageId
        self.translations = translations
        self.processed = processed
        self.readyForProcessing = readyForProcessing
    }

    func willCreate(on conn: MySQLConnection) throws -> Future<Package>
    {
        readyForProcessing = false
        processed = false
        return Future.map(on: conn) { self }
    }
}

extension Package
{
    var theme: Parent<Package, Theme> {
        return parent(\.themeId)
    }

    var language: Parent<Package, Language> {
        return parent(\.languageId)
    }
}

/// Allows `Package` to be used as a dynamic migration.
extension Package: Migration
{
    static func prepare(on conn: MySQLConnection) -> Future<Void>
    {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.themeId, \.languageId)
        }
    }
}

/// Allows `Package` to be encoded to and decoded from HTTP messages.
extension Package: Content { }

/// Allows `Package` to be used as a dynamic parameter in route definitions.
extension Package: Parameter { }
