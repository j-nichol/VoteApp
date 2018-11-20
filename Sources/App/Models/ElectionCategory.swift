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
