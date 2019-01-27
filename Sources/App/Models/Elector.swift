import Vapor
import FluentPostgreSQL

final class Elector: Codable {
    var id: UUID?
    var username: String
    var password: String
    var name: String
    
    init(username: String, password: String, name: String) {
        self.username = username
        self.password = password
        self.name = name
    }
}

extension Elector: PostgreSQLUUIDModel {}
extension Elector: Content {}
extension Elector: Parameter {}
extension Elector: Migration {}
extension Elector { var ballots: Children<Elector, Ballot> {return children(\.electorID)}}
extension Elector { var eligibilities: Children<Elector, Eligibility> {return children(\.electorID)}}

//when securing elctor passwords, remember to change anything (else) which returns an elector to return a public one.

