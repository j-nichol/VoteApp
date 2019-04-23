import Vapor
import FluentPostgreSQL
import Authentication

final class Admin: Codable {
  var id: UUID?
  var username: String
  var password: String
  
  init(username: String, password: String) {
    self.username = username
    self.password = password
  }
  
  final class Public: Codable {
    var id: UUID?
    var username: String
    
    init(id:UUID?, username:String) {
      self.id = id
      self.username = username
    }
  }
}

extension Admin: PostgreSQLUUIDModel {}
extension Admin: Content {}
extension Admin: Parameter {}
extension Admin.Public: Content {}
extension Admin: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
      return Database.create(self, on: connection) {
        builder in
        try addProperties(to: builder)
        builder.unique(on: \.username)
      }
  }
}
extension Admin {
  func convertToPublic() -> Admin.Public {
    return Admin.Public(id: id, username: username)
  }
}
extension Future where T: Admin {
  func convertToPublic() -> Future<Admin.Public> {
    return self.map(to: Admin.Public.self) {
      admin in
      return admin.convertToPublic()
    }
  }
}
extension Admin: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \Admin.username
  static let passwordKey: PasswordKey = \Admin.password
}

extension Admin: TokenAuthenticatable {
  typealias TokenType = Token
}

extension Admin: PasswordAuthenticatable {}
extension Admin: SessionAuthenticatable {}

///Preloaded data for testing purposes
struct AdminUser: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    let password = try? BCrypt.hash("password")
    guard let hashedPassword = password else {
      fatalError("Failed to create admin user")
    }
    let admin = Admin(username: "admin", password: hashedPassword)
    return admin.save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}


