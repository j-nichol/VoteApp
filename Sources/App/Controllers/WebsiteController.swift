import Vapor
import Leaf

struct WebsiteController: RouteCollection {
  func boot(router: Router) throws {
    router.get(use: indexHandler)
  }
  func indexHandler(_ req: Request) throws -> Future<View> {
    return Election.query(on: req).all().flatMap(to: View.self) {
      elections in
      let electionsData = elections.isEmpty ? nil : elections
      let context = IndexContext(title: "Homepage", elections: electionsData)
      return try req.view().render("index", context)
    }
  }
}

struct IndexContext: Encodable {
  let title: String
  let elections: [Election]?
}
