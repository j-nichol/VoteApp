import Vapor
import FluentPostgreSQL

/*
 
 Change to add parent
 
 */

final class Candidate: Codable {
    var id: Int?
    var name: String
    var partyID: String
    
    init(name: String, partyID: String) {
        self.name = name
        self.partyID = partyID
    }
}

extension Candidate: PostgreSQLModel {}
extension Candidate: Content {}
extension Candidate: Parameter {}
extension Candidate: Migration {}
