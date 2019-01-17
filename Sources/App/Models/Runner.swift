import Vapor
import FluentPostgreSQL

final class Runner: Codable {
    var id: Int?
    var candidateID: Candidate.ID
    var electionID: Election.ID
    
    init(candidateID: String, electionID: String) {
        self.candidateID = candidateID
        self.electionID = electionID
    }
}

extension Runner: PostgreSQLModel {}
extension Runner: Content {}
extension Runner: Parameter {}
extension Runner: Migration {}
