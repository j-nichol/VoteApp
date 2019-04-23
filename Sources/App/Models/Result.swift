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

///Preloaded data for testing purposes
extension Result: PostgreSQLModel {}
extension Result: Content {}
extension Result: Parameter {}
extension Result { var election: Parent<Result, Election> { return parent(\.electionID)}}
extension Result { var candidate: Parent<Result, Candidate> { return parent(\.candidateID)}}
extension Result: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.electionID, to: \Election.id)
            builder.reference(from: \.candidateID, to: \Candidate.id)
        }
    }
}
