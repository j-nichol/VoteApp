import Vapor
import FluentPostgreSQL

final class Runner: Codable {
    var id: Int?
    var candidateID: Candidate.ID
    var electionID: Election.ID
    
    init(candidateID: Candidate.ID, electionID: Election.ID) {
        self.candidateID = candidateID
        self.electionID = electionID
    }
}

extension Runner: PostgreSQLModel {}
extension Runner: Content {}
extension Runner: Parameter {}
extension Runner { var candidate: Parent<Runner, Candidate> { return parent(\.candidateID)}}
extension Runner { var election: Parent<Runner, Election> { return parent(\.electionID)}}
extension Runner: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.candidateID, to: \Candidate.id)
            builder.reference(from: \.electionID, to: \Election.id)
        }
    }
}
