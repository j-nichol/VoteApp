import Vapor
import FluentPostgreSQL
import Authentication

final class Elector: Codable {
  var id: UUID?
  var name: String
  var username: String
  var password: String
  
  init(name: String, username: String, password: String) {
    self.name = name
    self.username = username
    guard let hashedPassword = try? BCrypt.hash(password) else { fatalError("Failed to create Elector.") }
    self.password = hashedPassword
  }
  
  final class Public: Codable {
    var id: UUID?
    var username: String
    init(id: UUID?, username: String) {
      self.id = id
      self.username = username
    }
  }
}

extension Elector: PostgreSQLUUIDModel {}
extension Elector: Content {}
extension Elector.Public: Content {}
extension Elector: Parameter {}
//extension Elector { var ballots: Children<Elector, Ballot> {return children(\.electorID)}}
extension Elector { var eligibilities: Children<Elector, Eligibility> {return children(\.electorID)}}

extension Elector: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in try addProperties(to: builder); builder.unique(on: \.username) }
  }
}

extension Elector { func convertToPublic() -> Elector.Public { return Elector.Public(id: id, username: username) } }
extension Future where T: Elector { func convertToPublic() -> Future<Elector.Public> {
    return self.map(to: Elector.Public.self) { elector in return elector.convertToPublic() }
  }
}

extension Elector: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \Elector.username
  static let passwordKey: PasswordKey = \Elector.password
}

extension Elector: PasswordAuthenticatable {}
extension Elector: SessionAuthenticatable {}


//when securing elctor passwords, remember to change anything (else) which returns an elector to return a public one.

