import Vapor
import FluentPostgreSQL

/*

   change to add parents

*/

final class Eligibility: Codable {
    var id: Int?
    var electorateID: String
    var electionID: String
    
    init(electorateID: String, electionID: String) {
        self.electorateID = electorateID
        self.electionID = electionID
    }
}

extension Eligibility: PostgreSQLModel {}
extension Eligibility: Content {}
extension Eligibility: Parameter {}
extension Eligibility: Migration {}
