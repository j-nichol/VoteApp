import Vapor
import Fluent
import Leaf
import Authentication

struct WebsiteController: RouteCollection {
  
///Routes
  func boot(router: Router) throws {
    let authSessionRoutes = router.grouped(Admin.authSessionsMiddleware())
    authSessionRoutes.get(use: indexHandler)
    authSessionRoutes.get("login", use: loginHandler)
    authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
    authSessionRoutes.post("logout", use: logoutHandler) 
    
    let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<Admin>(path: "/login"))
    
/* Bin ->
    //protectedRoutes.get("elections", Election.parameter, use: electionHandler)
    //protectedRoutes.get("elections", "create", use: createElectionHandler)
    //protectedRoutes.post(CreateElectionData.self, at: "elections", "create", use: createElectionPostHandler)
<- Bin */
  }
  
///GETs
  //Index
  func indexHandler(_ req: Request) throws -> Future<View> {
    return try req.view().render("index", IndexContext(meta: Meta(title: "HomePage", isHelp: false, userLoggedIn: try req.isAuthenticated(Admin.self))))
  }
  
  //Login
  func loginHandler(_ req: Request) throws -> Future<View> {
    if (try req.isAuthenticated(Admin.self)) { return try req.view().render("/") } else {return try req.view().render("login", LoginContext(meta: Meta(title: "Log In", isHelp: false, userLoggedIn: false), loginError: (req.query[Bool.self, at: "error"] != nil)))}
  }
  
/* BIN ->
  //Election
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
  
  //CreateElection
  func createElectionHandler(_ req: Request) throws -> Future<View> {
    let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
    let context = CreateElectionContext(electionCategories: ElectionCategory.query(on: req).all(), csrfToken: token)
    try req.session()["CSRF_TOKEN"] = token
    return try req.view().render("createElection", context)
  }
<- BIN */
  
///POSTs
  
  //Log In
  func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
    return Admin.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(), on: req).map(to: Response.self) {
      admin in
      guard let admin = admin else { return req.redirect(to: "/login?error") }
      try req.authenticateSession(admin)
      return req.redirect(to: "/")
    }
  }
  
  //Log Out
  func logoutHandler(_ req: Request) throws -> Response {
    try req.unauthenticateSession(Admin.self)
    return req.redirect(to: "/")
  }
  
/* BIN ->
  //Create Election
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
<- BIN */

}

///Contexts
//Index
struct IndexContext: Encodable {
  let meta: Meta
}

//Login
struct LoginContext: Encodable {
  let meta: Meta
  var loginError: Bool
}

/* BIN ->
//Election
struct electionContext: Encodable {
  let title: String
  let election: Election
  let electionCategory: ElectionCategory
}
//Create Election
struct CreateElectionContext: Encodable {
  let title = "Create an Election"
  let electionCategories: Future<[ElectionCategory]>
  let csrfToken: String
}
<- BIN */

/// Data Types

//Page Meta
struct Meta: Content {
  let title: String
  let isHelp: Bool
  let userLoggedIn: Bool
}

//Login Data
struct LoginPostData: Content {
  let username: String
  let password: String
}

/* BIN ->
//Create Election Data
struct CreateElectionData: Content {
  let name: String
  let electionCategoryID: Int
  let csrfToken: String
}
<- BIN */

///Notes
/*
 // Code similar to this will allow you to steal variables out of the session.
 
 let user = try req.requireAuthenticated(User.self)
 let acronym = try Acronym(
 short: data.short,
 long: data.long,
 userID: user.requireID())”
 */

//Will need to add userLoggedIn to pretty much every page... Unless 

/*
 //Useful info for passing db info to page
 return Election.query(on: req).all().flatMap(to: View.self) {
 elections in
 let electionsData = elections.isEmpty ? nil : elections
 let userLoggedIn = try req.isAuthenticated(Admin.self)
 let context = IndexContext(title: "Homepage", elections: electionsData, userLoggedIn: userLoggedIn)
 return try req.view().render("index", context)
 */
