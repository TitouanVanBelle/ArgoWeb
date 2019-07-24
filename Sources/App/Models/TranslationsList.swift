import FluentPostgreSQL
import Vapor

final class TranslationsList: PostgreSQLModel
{
    var id: Int?
    var packageId: Int
    var languageId: Int
    var translations: [String]?

    init(id: Int? = nil, packageId: Int, languageId: Int, translations: [String]? = nil)
    {
        self.id = id
        self.packageId = packageId
        self.languageId = languageId
        self.translations = translations
    }
}

extension TranslationsList
{
    var package: Parent<TranslationsList, Package> {
        return parent(\.packageId)
    }

    var language: Parent<TranslationsList, Language> {
        return parent(\.languageId)
    }
}

/// Allows `TranslationsList` to be used as a dynamic migration.
extension TranslationsList: Migration
{
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void>
    {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.packageId, \.languageId)
        }
    }
}

/// Allows `TranslationsList` to be encoded to and decoded from HTTP messages.
extension TranslationsList: Content { }

/// Allows `TranslationsList` to be used as a dynamic parameter in route definitions.
extension TranslationsList: Parameter { }
