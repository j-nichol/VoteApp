import Vapor
import FluentPostgreSQL

final class Eligibility: Codable {
    var id: Int?
    var electorID: Elector.ID
    var electionID: Election.ID
    
    init(electorID: Elector.ID, electionID: Election.ID) {
        self.electorID = electorID
        self.electionID = electionID
    }
}

extension Eligibility: PostgreSQLModel {}
extension Eligibility: Content {}
extension Eligibility: Parameter {}
extension Eligibility: Migration {}
