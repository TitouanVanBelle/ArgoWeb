import Vapor

struct IndexContext: Encodable
{
    let currentPath: String
    let languagesCount: Future<Int>
    let packagesCount: Future<Int>
    let themesCount: Future<Int>
    let user: User
}
