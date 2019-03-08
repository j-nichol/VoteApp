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

struct ElectoratePreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    
    
    _ = Elector(name: "Voter One",      username: "VoteOnex1234", password: "CatTomato45").save(on: connection)
    _ = Elector(name: "Voter Two",      username: "VoteTwox2345", password: "DogParsnip92").save(on: connection)
    _ = Elector(name: "Voter Three",    username: "VoteThre3456", password: "HamsterCarrot12").save(on: connection)
    _ = Elector(name: "Voter Four",     username: "VoteFour4567", password: "RatPotato47").save(on: connection)
    _ = Elector(name: "Voter Five",     username: "VoteFive5678", password: "ParrotOnion74").save(on: connection)
    _ = Elector(name: "Voter Six",      username: "VoteSixx6789", password: "MonkeyPepper84").save(on: connection)
    _ = Elector(name: "Voter Seven",    username: "VoteSeve7891", password: "FishTurnip64").save(on: connection)
    _ = Elector(name: "Voter Eight",    username: "VoteEigh8910", password: "DolphinApple53").save(on: connection)
    _ = Elector(name: "Voter Nine",     username: "VoteNine9101", password: "WhaleBanana49").save(on: connection)
    _ = Elector(name: "Voter Ten",      username: "VoteTenx1011", password: "OctopusPear54").save(on: connection)
    _ = Elector(name: "Voter Eleven",   username: "VoteElev1112", password: "MousePineapple28").save(on: connection)
    _ = Elector(name: "Voter Twelve",   username: "VoteTwel1213", password: "HorseOrange34").save(on: connection)
    _ = Elector(name: "Voter Thirteen", username: "VoteThir1314", password: "DonkeyPapaya97").save(on: connection)
    _ = Elector(name: "Voter Fourteen", username: "VoteFour1415", password: "ZebraLime84").save(on: connection)
    return Elector(name: "Voter Fifteen",  username: "VoteFift1516", password: "GiraffeLemon12").save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
