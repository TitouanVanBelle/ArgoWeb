import Vapor

/// Controls basic CRUD operations on `Flashcard`s.
final class FlashcardController {
    /// Returns a list of all `Flashcard`s.
    func index(_ req: Request) throws -> Future<[Flashcard]> {
        return Flashcard.query(on: req).all()
    }

    /// Saves a decoded `Flashcard` to the database.
    func create(_ req: Request) throws -> Future<Flashcard> {
        return try req.content.decode(Flashcard.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Flashcard`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Flashcard.self).flatMap { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }
}
