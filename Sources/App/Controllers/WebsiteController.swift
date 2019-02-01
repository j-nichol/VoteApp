import Vapor
import Fluent
import Leaf
import Authentication

struct WebsiteController: RouteCollection {
  
  func boot(router: Router) throws {
    /*
    router.get(use: indexHandler)
    router.get("elections", Election.parameter, use: electionHandler)
    router.get("elections", "create", use: createElectionHandler)
    router.post(Election.self, at: "elections", "create", use: createElectionPostHandler)
    router.get("login", use: loginHandler)
    router.post(LoginPostData.self, at: "login", use: loginPostHandler)
     */
    let authSessionRoutes = router.grouped(Admin.authSessionsMiddleware())
    authSessionRoutes.get(use: indexHandler)
    authSessionRoutes.get("login", use: loginHandler)
    authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
    authSessionRoutes.post("logout", use: logoutHandler) 
    
    let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<Admin>(path: "/login"))
    protectedRoutes.get("elections", Election.parameter, use: electionHandler)
    protectedRoutes.get("elections", "create", use: createElectionHandler)
    protectedRoutes.post(CreateElectionData.self, at: "elections", "create", use: createElectionPostHandler)
  }
  
  func indexHandler(_ req: Request) throws -> Future<View> {
    return Election.query(on: req).all().flatMap(to: View.self) {
      elections in
      let electionsData = elections.isEmpty ? nil : elections
      let userLoggedIn = try req.isAuthenticated(Admin.self) ///would need to add this to each page, I think.
      let isHelp = false
      let context = IndexContext(title: "Homepage", elections: electionsData, userLoggedIn: userLoggedIn)
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
    let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
    let context = CreateElectionContext(electionCategories: ElectionCategory.query(on: req).all(), csrfToken: token)
    try req.session()["CSRF_TOKEN"] = token
    return try req.view().render("createElection", context)
    /*
    // Code similar to this will allow you to steal variables out of the session.
     
    let user = try req.requireAuthenticated(User.self)
    let acronym = try Acronym(
      short: data.short,
      long: data.long,
      userID: user.requireID())”
    */
  }
  
  func createElectionPostHandler(_ req: Request, data: CreateElectionData) throws -> Future<Response> {
    let expectedToken = try req.session()["CSRF_TOKEN"]
    try req.session()["CSRF_TOKEN"] = nil
    guard expectedToken == data.csrfToken else { throw Abort(.badRequest) }
    let election = Election(name: data.name, electionCategoryID: data.electionCategoryID)
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
  let userLoggedIn: Bool ///would need to add this to each page. I think.
  let isHelp = false
}

struct electionContext: Encodable {
  let title: String
  let election: Election
  let electionCategory: ElectionCategory
}

struct CreateElectionContext: Encodable {
  let title = "Create an Election"
  let electionCategories: Future<[ElectionCategory]>
  let csrfToken: String
}


struct LoginContext: Encodable {
  let title = "Log In"
  let userLoggedIn: Bool ///would need to add this to each page. I think.
  let isHelp = false
  
  let loginError: Bool
  init(loginError: Bool = false, userLoggedIn: Bool = false) {
    self.loginError = loginError
    self.userLoggedIn = userLoggedIn
  }
}

func loginHandler(_ req: Request) throws -> Future<View> {
  let context: LoginContext
  let userLoggedIn = try req.isAuthenticated(Admin.self)
  if req.query[Bool.self, at: "error"] != nil {
    context = LoginContext(loginError: true, userLoggedIn: userLoggedIn)
  } else {
    context = LoginContext(userLoggedIn: userLoggedIn)
  }
  return try req.view().render("login", context)
}

struct LoginPostData: Content {
  let username: String
  let password: String
}

func logoutHandler(_ req: Request) throws -> Response {
  try req.unauthenticateSession(Admin.self)
  return req.redirect(to: "/")
}

struct CreateElectionData: Content {
  let name: String
  let electionCategoryID: Int
  let csrfToken: String
}
