import Vapor
import FluentPostgreSQL

/*
 
 change to add parents
 
 */

final class Runner: Codable {
    var id: Int?
    var candidateID: String
    var electionID: String
    
    init(candidateID: String, electionID: String) {
        self.candidateID = candidateID
        self.electionID = electionID
    }
}

extension Runner: PostgreSQLModel {}
extension Runner: Content {}
extension Runner: Parameter {}
extension Runner: Migration {}
