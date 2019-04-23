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

///Preloaded data for testing purposes
struct RunnersPreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    
    _ = Runner(candidateID: 1, electionID: 1).save(on: connection)
    _ = Runner(candidateID: 1, electionID: 2).save(on: connection)
    _ = Runner(candidateID: 1, electionID: 3).save(on: connection)
    _ = Runner(candidateID: 1, electionID: 4).save(on: connection)
    _ = Runner(candidateID: 1, electionID: 5).save(on: connection)
    _ = Runner(candidateID: 2, electionID: 1).save(on: connection)
    _ = Runner(candidateID: 3, electionID: 2).save(on: connection)
    _ = Runner(candidateID: 4, electionID: 3).save(on: connection)
    _ = Runner(candidateID: 5, electionID: 4).save(on: connection)
    _ = Runner(candidateID: 6, electionID: 5).save(on: connection)
    _ = Runner(candidateID: 7, electionID: 1).save(on: connection)
    _ = Runner(candidateID: 8, electionID: 2).save(on: connection)
    _ = Runner(candidateID: 9, electionID: 3).save(on: connection)
    _ = Runner(candidateID: 10, electionID: 4).save(on: connection)
    _ = Runner(candidateID: 11, electionID: 5).save(on: connection)
    _ = Runner(candidateID: 12, electionID: 1).save(on: connection)
    _ = Runner(candidateID: 13, electionID: 2).save(on: connection)
    _ = Runner(candidateID: 14, electionID: 3).save(on: connection)
    _ = Runner(candidateID: 15, electionID: 4).save(on: connection)
    return Runner(candidateID: 16, electionID: 5).save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
