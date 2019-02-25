import Vapor
import FluentPostgreSQL

final class Ballot: Codable {
  var id: Int?
  var ballotChecker: String //hash
  var encryptedBallotData: Data
  var encryptedBallotTag: Data
  var ballotInitialisationVector: String

  init(ballotChecker: String, encryptedBallotData: Data, encryptedBallotTag: Data, ballotInitialisationVector: String) {
    self.ballotChecker = ballotChecker
    self.encryptedBallotData = encryptedBallotData
    self.encryptedBallotTag = encryptedBallotTag
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
