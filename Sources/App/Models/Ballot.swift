import Vapor
import FluentPostgreSQL

/*
 
    Change to add parent
 
 */

final class Ballot: Codable {
    var id: Int?
    var electorateID: String
    var encryptedBallot: String
    var ballotChecker: String
    
    init(electorateID: String, encryptedBallot: String, ballotChecker: String) {
        self.electorateID = electorateID
        self.encryptedBallot = encryptedBallot
        self.ballotChecker = ballotChecker
    }
}

extension Ballot: PostgreSQLModel {}
extension Ballot: Content {}
extension Ballot: Parameter {}
extension Ballot: Migration {}
