import Vapor
import FluentPostgreSQL

final class Candidate: Codable {
    var id: Int?
    var name: String
    var partyID: Party.ID
    
    init(name: String, partyID: Party.ID) {
        self.name = name
        self.partyID = partyID
    }
}

extension Candidate: PostgreSQLModel {}
extension Candidate: Content {}
extension Candidate: Parameter {}
extension Candidate { var party: Parent<Candidate, Party> { return parent(\.partyID)}}
extension Candidate: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.partyID, to: \Party.id)
        }
    }
}
extension Candidate { var results: Children<Candidate, Result> {return children(\.candidateID)}}
extension Candidate { var runners: Children<Candidate, Runner> {return children(\.candidateID)}}

struct CandidatesPreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    
    _ = Candidate(name: "Spoil Ballot", partyID: 1).save(on: connection)
    _ = Candidate(name: "Mathias Sweet", partyID: 2).save(on: connection)
    _ = Candidate(name: "Kellie Stephens", partyID: 2).save(on: connection)
    _ = Candidate(name: "Oliver Gough", partyID: 2).save(on: connection)
    _ = Candidate(name: "Julie Dalton", partyID: 2).save(on: connection)
    _ = Candidate(name: "Abbey Gallagher", partyID: 2).save(on: connection)
    _ = Candidate(name: "Marion Milner", partyID: 3).save(on: connection)
    _ = Candidate(name: "Nicholas Hamer", partyID: 3).save(on: connection)
    _ = Candidate(name: "Myles McGill", partyID: 3).save(on: connection)
    _ = Candidate(name: "Amie Vang", partyID: 3).save(on: connection)
    _ = Candidate(name: "Marc Walton", partyID: 3).save(on: connection)
    _ = Candidate(name: "Emelia Buckner", partyID: 4).save(on: connection)
    _ = Candidate(name: "Riyad Beatie", partyID: 4).save(on: connection)
    _ = Candidate(name: "Lance David", partyID: 4).save(on: connection)
    _ = Candidate(name: "Grace Andrew", partyID: 4).save(on: connection)
    return Candidate(name: "Vernon Sparrow", partyID: 4).save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
