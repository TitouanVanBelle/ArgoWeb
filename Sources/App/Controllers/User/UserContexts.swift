import Vapor

struct UserRegisterContext: Encodable
{
    let errorMessage: String?
    let languages: [Language]
}
