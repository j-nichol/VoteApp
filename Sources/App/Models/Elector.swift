import Vapor
import FluentPostgreSQL

final class Elector: Codable {
    var id: Int?
    var username: String
    var password: String
    var name: String
    
    init(username: String, password: String, name: String) {
        self.username = username
        self.password = password
        self.name = name
    }
}

extension Elector: PostgreSQLModel {}
extension Elector: Content {}
extension Elector: Parameter {}
extension Elector: Migration {}
