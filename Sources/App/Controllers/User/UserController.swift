import Foundation
import Vapor
import Fluent
import Crypto

enum RegisterError: Int, Encodable {
    case userAlreadyExist = 1

    var errorMessage: String {
        switch self {
        case .userAlreadyExist:
            return "A user already exists with this email"
        }
    }
}

class UserController
{
    func renderRegister(_ req: Request) throws -> Future<View>
    {
        var error: RegisterError?
        if let errorValue = req.query[Int.self, at: "error"]  {
            error = RegisterError(rawValue: errorValue)
        }

        let languages = Language.query(on: req).all()
        return languages.flatMap { languages in
            let context = UserRegisterContext(
                errorMessage: error?.errorMessage,
                languages: languages
            )
            return try req.view().render("register", context)
        }
    }

    func renderLogin(_ req: Request) throws -> Future<View>
    {
        return try req.view().render("login")
    }

    func register(_ req: Request) throws -> Future<Response>
    {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { existingUser in
                guard existingUser == nil else {
                    return Future.map(on: req) {
                        return req.redirect(to: "/register?error=1")
                    }
                }

                user.password = try BCryptDigest().hash(user.password)
                user.admin = false

                return user.save(on: req).map { _ in
                    return req.redirect(to: "/login")
                }
            }
        }
    }

    func login(_ req: Request) throws -> Future<Response>
    {
        return try req.content.decode(User.UserLoginForm.self).flatMap { userForm in
            return User.authenticate(
                username: userForm.email,
                password: userForm.password,
                using: BCryptDigest(),
                on: req
                ).map { user in
                    guard let user = user else {
                        return req.redirect(to: "/login")
                    }
                    try req.authenticateSession(user)
                    return req.redirect(to: "/")
            }
        }
    }

    func logout(_ req: Request) throws -> Future<Response>
    {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { return req.redirect(to: "/login") }
    }
}
