import Vapor
import FluentPostgreSQL

final class Election: Codable {
    var id: Int?
    var name: String
    var electionCategoryID: ElectionCategory.ID
    
    init(name: String, electionCategoryID: ElectionCategory.ID) {
        self.name = name
        self.electionCategoryID = electionCategoryID
    }
}

extension Election: PostgreSQLModel {}
extension Election: Content {}
extension Election: Parameter {}
extension Election: Migration {}
