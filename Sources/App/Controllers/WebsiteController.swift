import Vapor
import Leaf

struct WebsiteController: RouteCollection {
  
  func boot(router: Router) throws {
    router.get(use: indexHandler)
    router.get("elections", Election.parameter, use: electionHandler)
  }
  
  func indexHandler(_ req: Request) throws -> Future<View> {
    return Election.query(on: req).all().flatMap(to: View.self) {
      elections in
      let electionsData = elections.isEmpty ? nil : elections
      let context = IndexContext(title: "Homepage", elections: electionsData)
      return try req.view().render("index", context)
    }
  }
  
  func electionHandler(_ req: Request) throws -> Future<View> {
    return try req.parameters.next(Election.self).flatMap(to: View.self) {
     election in
      return election.electionCategory.get(on: req).flatMap(to: View.self) {
        electionCategory in
        let context = electionContext(title: election.name, election: election, electionCategory: electionCategory)
        return try req.view().render("election", context)
      }
    }
  }

}

struct IndexContext: Encodable {
  let title: String
  let elections: [Election]?
}

struct electionContext: Encodable {
  let title: String
  let election: Election
  let electionCategory: ElectionCategory
}
