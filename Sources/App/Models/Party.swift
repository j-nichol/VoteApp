import Vapor
import FluentPostgreSQL

final class Party: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Party: PostgreSQLModel {}
extension Party: Content {}
extension Party: Parameter {}
extension Party: Migration {}
extension Party { var candidates: Children<Party, Candidate> {return children(\.partyID)}}

struct PartiesPreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    
    _ = Party(name: "Red Party").save(on: connection)
    _ = Party(name: "Green Party").save(on: connection)
    _ = Party(name: "Blue Party").save(on: connection)
    return Party(name: "Select this option to spoil your ballot. Your ballot will still be counted, but no candidate will receive your vote.").save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
