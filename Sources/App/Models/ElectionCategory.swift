import Vapor
import FluentPostgreSQL

final class ElectionCategory: Codable {
    var id: Int?
    var name: String
    var startDate: Date
    var endDate: Date
    
    init(name: String, startDate: String, endDate: String) {
      self.name = name
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      self.startDate = dateFormatter.date(from: startDate)!
      self.endDate = dateFormatter.date(from: endDate)!

    }
}

extension ElectionCategory: PostgreSQLModel {}
extension ElectionCategory: Content {}
extension ElectionCategory: Parameter {}
extension ElectionCategory: Migration {}
extension ElectionCategory { var elections: Children<ElectionCategory, Election> {return children(\.electionCategoryID)}}

