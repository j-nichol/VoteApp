import Vapor
import FluentPostgreSQL

final class Ballot: Codable {
    var id: Int?
    var electorID: Elector.ID
    var encryptedBallot: String
    var ballotChecker: String
    
    init(electorateID: Elector.ID, encryptedBallot: String, ballotChecker: String) {
        self.electorID = electorateID
        self.encryptedBallot = encryptedBallot
        self.ballotChecker = ballotChecker
    }
}

extension Ballot: PostgreSQLModel {}
extension Ballot: Content {}
extension Ballot: Parameter {}
extension Ballot { var elector: Parent<Ballot, Elector> { return parent(\.electorID)}}
extension Ballot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.electorID, to: \Elector.id)
        }
    }
}
