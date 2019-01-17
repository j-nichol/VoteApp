import Vapor
import FluentPostgreSQL

final class Candidate: Codable {
    var id: Int?
    var name: String
    var partyID: Party.ID
    
    init(name: String, partyID: Party.ID) {
        self.name = name
        self.partyID = partyID
    }
}

extension Candidate: PostgreSQLModel {}
extension Candidate: Content {}
extension Candidate: Parameter {}
extension Candidate { var party: Parent<Candidate, Party> { return parent(\.partyID)}}
extension Candidate: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) {
            builder in
            try addProperties(to: builder)
            builder.reference(from: \.partyID, to: \Party.id)
        }
    }
}
extension Candidate { var results: Children<Candidate, Result> {return children(\.id)}}
extension Candidate { var runners: Children<Candidate, Runner> {return children(\.id)}}

