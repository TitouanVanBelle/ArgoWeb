import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

final class User: PostgreSQLModel
{
    struct UserLoginForm: Content {
        let email: String
        let password: String
    }

    var id: Int?
    var email: String
    var password: String
    var admin: Bool? = false
    var languageId: Int

    init(id: Int? = nil, email: String, password: String, admin: Bool? = false, languageId: Int)
    {
        self.id = id
        self.email = email
        self.password = password
        self.admin = admin
        self.languageId = languageId
    }

    func willCreate(on conn: PostgreSQLConnection) throws -> EventLoopFuture<User>
    {
        if email == "titouan.vanbelle@gmail.com" {
            admin = true
        }

        return Future.map(on: conn) { self }
    }
}

extension User: PasswordAuthenticatable
{
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.email
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}

extension User: SessionAuthenticatable {}

/// Allows `TranslationsList` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `TranslationsList` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `TranslationsList` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
