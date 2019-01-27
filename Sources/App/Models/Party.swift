import Vapor
import FluentPostgreSQL

final class Party: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Party: PostgreSQLModel {}
extension Party: Content {}
extension Party: Parameter {}
extension Party: Migration {}
extension Party { var candidates: Children<Party, Candidate> {return children(\.partyID)}}


