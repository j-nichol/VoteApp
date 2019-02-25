import Vapor
import FluentPostgreSQL

final class Ballot: Codable {
    var id: Int?
    var ballotChecker: String //hash
    var encryptedBallot: Data
    var ballotInitialisationVector: Data
    
    init(ballotChecker: String, encryptedBallot: Data, ballotInitialisationVector: Data) {
        self.ballotChecker = ballotChecker
        self.encryptedBallot = encryptedBallot
        self.ballotInitialisationVector = ballotInitialisationVector
    }
}

extension Ballot: PostgreSQLModel {}
extension Ballot: Content {}
extension Ballot: Parameter {}
extension Ballot: Migration {}

//extension Ballot { var elector: Parent<Ballot, Elector> { return parent(\.electorID)}}
//extension Ballot: Migration {
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) {
//            builder in
//            try addProperties(to: builder)
//            builder.reference(from: \.electorID, to: \Elector.id)
//        }
//    }
//}
