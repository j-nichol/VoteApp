import Vapor
import FluentPostgreSQL

final class Result: Codable {
    var id: Int?
    var electionID: Election.ID
    var candidateID: Candidate.ID
    var voteCount: Int
    
    init(electionID: Election.ID, candidateID: Candidate.ID) {
        self.electionID = electionID
        self.candidateID = candidateID
        self.voteCount = 0
    }
}

extension Result: PostgreSQLModel {}
extension Result: Content {}
extension Result: Parameter {}
extension Result: Migration {}
