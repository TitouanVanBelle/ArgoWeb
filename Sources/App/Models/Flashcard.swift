import FluentMySQL
import Vapor

/// A single entry of a Flashcard list.
final class Flashcard: MySQLModel
{
    var id: Int?
    var word: String
    var translation: String
    var package: Package

    init(id: Int? = nil, word: String, translation: String, package: Package)
    {
        self.id = id
        self.word = word
        self.translation = translation
        self.package = package
    }
}

/// Allows `Flashcard` to be used as a dynamic migration.
extension Flashcard: Migration { }

/// Allows `Flashcard` to be encoded to and decoded from HTTP messages.
extension Flashcard: Content { }

/// Allows `Flashcard` to be used as a dynamic parameter in route definitions.
extension Flashcard: Parameter { }
