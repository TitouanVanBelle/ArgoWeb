import Vapor

struct IndexContext: Encodable
{
    let currentPath: String
    let languagesCount: Future<Int>
    let translationsListsCount: Future<Int>
    let packagesCount: Future<Int>
    let user: User
    let apiKeyA: String
    let apiKeyB: String
}
