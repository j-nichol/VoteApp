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
extension Election { var electionCategory: Parent<Election, ElectionCategory> { return parent(\.electionCategoryID)}}
extension Election: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.electionCategoryID, to: \ElectionCategory.id)
        }
    }
}
extension Election { var eligibilities: Children<Election, Eligibility> {return children(\.electionID)}}
extension Election { var results: Children<Election, Result> {return children(\.electionID)}}
extension Election { var runners: Children<Election, Runner> {return children(\.electionID)}}

