import Vapor
import FluentPostgreSQL

final class Eligibility: Codable {
    var id: Int?
    var electorID: Elector.ID
    var electionID: Election.ID
    var hasVoted: Bool = false
    
    init(electorID: Elector.ID, electionID: Election.ID) {
        self.electorID = electorID
        self.electionID = electionID
    }
  
  
}

extension Eligibility: PostgreSQLModel {}
extension Eligibility: Content {}
extension Eligibility: Parameter {}
extension Eligibility { var elector: Parent<Eligibility, Elector> { return parent(\.electorID)}}
extension Eligibility { var election: Parent<Eligibility, Election> { return parent(\.electionID)}}
extension Eligibility: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.electorID, to: \Elector.id)
            builder.reference(from: \.electionID, to: \Election.id)
        }
    }
}
