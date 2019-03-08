import Vapor
import FluentPostgreSQL

final class ElectionCategory: Codable {
    var id: Int?
    var name: String
    var startDate: String
    var endDate: String
    
    init(name: String, startDate: String, endDate: String) {
      self.name = name
      self.startDate = startDate
      self.endDate = endDate

    }
}

extension ElectionCategory: PostgreSQLModel {}
extension ElectionCategory: Content {}
extension ElectionCategory: Parameter {}
extension ElectionCategory: Migration {}
extension ElectionCategory { var elections: Children<ElectionCategory, Election> {return children(\.electionCategoryID)}}

struct ElectionCategoriesPreload: Migration {
  typealias Database = PostgreSQLDatabase
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return ElectionCategory(name: "General Election 2019", startDate: "2019-01-21T10:00:00Z", endDate: "2019-04-21T22:00:00Z").save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
