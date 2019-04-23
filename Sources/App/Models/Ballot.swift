import Vapor
import FluentPostgreSQL

final class Ballot: Codable {
  var id: Int?
  var ballotChecker: String 
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
