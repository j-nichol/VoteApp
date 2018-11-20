import Vapor
import FluentPostgreSQL

/*
 
 Change to add parent
 
 */

final class Election: Codable {
    var id: Int?
    var name: String
    var electionCategoryID: String
    
    init(name: String, electionCategoryID: String) {
        self.name = name
        self.electionCategoryID = electionCategoryID
    }
}

extension Election: PostgreSQLModel {}
extension Election: Content {}
extension Election: Parameter {}
extension Election: Migration {}
