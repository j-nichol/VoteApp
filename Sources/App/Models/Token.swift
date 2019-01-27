import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
  var id: UUID?
  var token: String
  var adminID: Admin.ID
  
  init(token: String, adminID: Admin.ID) {
    self.token = token
    self.adminID = adminID
  }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) {
      builder in
      try addProperties(to: builder)
      builder.reference(from: \.adminID, to: \Admin.id)
    }
  }
}

extension Token: Content{}

extension Token {
  static func generate(for user: Admin)  throws -> Token {
    let random = try CryptoRandom().generateData(count: 16)
    return try Token(token: random.base64EncodedString(), adminID: user.requireID())
  }
}

extension Token: Authentication.Token {
  static let userIDKey: UserIDKey = \Token.adminID
  typealias UserType = Admin
}

extension Token: BearerAuthenticatable {
  static let tokenKey: TokenKey = \Token.token
}
