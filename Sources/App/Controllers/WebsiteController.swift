import Vapor
import Fluent
import Leaf
import Authentication

struct WebsiteController: RouteCollection {
  
  func boot(router: Router) throws {
    router.get(use: indexHandler)
    router.get("elections", Election.parameter, use: electionHandler)
    router.get("elections", "create", use: createElectionHandler)
    router.post(Election.self, at: "elections", "create", use: createElectionPostHandler)
    router.get("login", use: loginHandler)
    router.post(LoginPostData.self, at: "login", use: loginPostHandler)
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
  
  func createElectionHandler(_ req: Request) throws -> Future<View> {
    let context = CreateElectionContext(electionCategories: ElectionCategory.query(on: req).all())
    return try req.view().render("createElection", context)
  }
  
  func createElectionPostHandler(_ req: Request, election: Election) throws -> Future<Response> {
    return election.save(on: req).map(to: Response.self) {
      election in
      guard let id = election.id else {
        throw Abort(.internalServerError)
      }
      return req.redirect(to: "/elections/\(id)")
    }
  }
  
  func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
    return Admin.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(), on: req).map(to: Response.self) {
      admin in
      guard let admin = admin else {
        return req.redirect(to:  "/login?error")
      }
      try req.authenticateSession(admin)
      return req.redirect(to: "/")
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

struct CreateElectionContext: Encodable {
  let title = "Create an Election"
  let electionCategories: Future<[ElectionCategory]>
}


struct LoginContext: Encodable {
  let title = "Log In"
  let loginError: Bool
  
  init(loginError: Bool = false) {
    self.loginError = loginError
  }
}

func loginHandler(_ req: Request) throws -> Future<View> {
  let context: LoginContext
  if req.query[Bool.self, at: "error"] != nil {
    context = LoginContext(loginError: true)
  } else {
    context = LoginContext()
  }
  return try req.view().render("login", context)
}

struct LoginPostData: Content {
  let username: String
  let password: String
}
