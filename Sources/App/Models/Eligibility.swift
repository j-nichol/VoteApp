import Vapor
import FluentPostgreSQL

final class Eligibility: Codable {
  var id: Int?
  var electorID: Elector.ID
  var electionID: Election.ID
  var hasVoted: Bool
    
  init(electorID: Elector.ID, electionID: Election.ID, hasVoted: Bool = false) {
    self.electorID = electorID
    self.electionID = electionID
    self.hasVoted = hasVoted
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

///Preloaded data for testing purposes
struct EligibilitiesPreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    
    return Elector.query(on: connection).decode(data: Elector.Public.self).all().map() {
      electors in
      _ = Eligibility(electorID: electors[0].id!, electionID: 1).save(on: connection)
      _ = Eligibility(electorID: electors[1].id!, electionID: 2).save(on: connection)
      _ = Eligibility(electorID: electors[2].id!, electionID: 3).save(on: connection)
      _ = Eligibility(electorID: electors[3].id!, electionID: 4).save(on: connection)
      _ = Eligibility(electorID: electors[4].id!, electionID: 5).save(on: connection)
      _ = Eligibility(electorID: electors[5].id!, electionID: 1).save(on: connection)
      _ = Eligibility(electorID: electors[6].id!, electionID: 2).save(on: connection)
      _ = Eligibility(electorID: electors[7].id!, electionID: 3).save(on: connection)
      _ = Eligibility(electorID: electors[8].id!, electionID: 4).save(on: connection)
      _ = Eligibility(electorID: electors[9].id!, electionID: 5).save(on: connection)
      _ = Eligibility(electorID: electors[10].id!, electionID: 1).save(on: connection)
      _ = Eligibility(electorID: electors[11].id!, electionID: 2).save(on: connection)
      _ = Eligibility(electorID: electors[12].id!, electionID: 3).save(on: connection)
      _ = Eligibility(electorID: electors[13].id!, electionID: 4).save(on: connection)
      _ = Eligibility(electorID: electors[14].id!, electionID: 5).save(on: connection)
    }

  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}

