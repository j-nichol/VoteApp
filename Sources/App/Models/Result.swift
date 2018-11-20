import Vapor
import FluentPostgreSQL

/*
 
    Change to add children
 
 */

final class Result: Codable {
    var id: Int?
    var electionID: String
    var candidateID: String
    var voteCount: Int
    
    init(electionID: String, candidateID: String) {
        self.electionID = electionID
        self.candidateID = candidateID
        self.voteCount = 0
    }
}

extension Result: PostgreSQLModel {}
extension Result: Content {}
extension Result: Parameter {}
extension Result: Migration {}
