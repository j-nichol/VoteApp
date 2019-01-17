import Vapor
import FluentPostgreSQL

final class Candidate: Codable {
    var id: Int?
    var name: String
    var partyID: Party.ID
    
    init(name: String, partyID: Party.ID) {
        self.name = name
        self.partyID = partyID
    }
}

extension Candidate: PostgreSQLModel {}
extension Candidate: Content {}
extension Candidate: Parameter {}
extension Candidate: Migration {}
