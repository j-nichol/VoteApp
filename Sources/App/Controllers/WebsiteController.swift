import Vapor
import Fluent
import Leaf
import Authentication
import Crypto

struct WebsiteController: RouteCollection {
  
///Routes
  func boot(router: Router) throws {
    let authSessionRoutes = router.grouped(Elector.authSessionsMiddleware())
    authSessionRoutes.get(use: indexHandler)
    authSessionRoutes.get("login", use: loginHandler)
    authSessionRoutes.post(LoginData.self, at: "login", use: loginPostHandler)
    authSessionRoutes.post("logout", use: logoutHandler)
    
    let tokenGuardAuthMiddleWare = Admin.guardAuthMiddleware()
    let tokenAuthMiddleWare = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = authSessionRoutes.grouped(tokenAuthMiddleWare, tokenGuardAuthMiddleWare)
    tokenAuthGroup.post(PreloadDataHolder.self, at: "preload", use: preloadHandler)
    
    
    let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<Elector>(path: "/login"))
    protectedRoutes.get("elections", use: electionsHandler)
    protectedRoutes.get("ballot", Election.parameter, use: ballotHandler)
    protectedRoutes.get("confirm", Election.parameter, Candidate.parameter, use: confirmHandler)
    
/* Bin ->
    //protectedRoutes.get("elections", Election.parameter, use: electionHandler)
    //protectedRoutes.get("elections", "create", use: createElectionHandler)
    //protectedRoutes.post(CreateElectionData.self, at: "elections", "create", use: createElectionPostHandler)
<- Bin */
  }
  
///GETs
  //Index
  func indexHandler(_ req: Request) throws -> Future<View> {
    if (try req.isAuthenticated(Elector.self)) {
      return try electionsHandler(_: req)
    }
    return try req.view().render("index", IndexContext(meta: Meta(title: "HomePage", isHelp: false, userLoggedIn: try req.isAuthenticated(Elector.self))))
  }
  
  //Login
  func loginHandler(_ req: Request) throws -> Future<View> {
    if (try req.isAuthenticated(Elector.self)) {
      return try electionsHandler(_: req)
    }
    let csrfToken = try CryptoRandom().generateData(count: 16).base64EncodedString()
    try req.session()["CSRF_TOKEN"] = csrfToken
    if (try req.isAuthenticated(Elector.self)) { return try electionsHandler(_: req) } else {return try req.view().render("login", LoginContext(meta: Meta(title: "Log In", isHelp: false, userLoggedIn: false), loginError: (req.query[Bool.self, at: "error"] != nil), csrfToken: csrfToken))}
  }
  
  func electionsHandler(_ req: Request) throws -> Future<View> {
    let user = try req.requireAuthenticated(Elector.self)
    let elections = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).all()
    let electionCategories = ElectionCategory.query(on: req).join(\Election.electionCategoryID, to: \ElectionCategory.id).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).all()
    
    return try req.view().render("elections", ElectionsContext(meta: Meta(title: "Elections", isHelp: false, userLoggedIn: try req.isAuthenticated(Elector.self)), name: user.name, elections: elections, electionCategories: electionCategories))
  }
  
  func ballotHandler(_ req: Request) throws -> Future<View> {
    return try req.parameters.next(Election.self).flatMap(to: View.self) {
      election in
      
      let user = try req.requireAuthenticated(Elector.self)
      //check eligible. If so return election //must check exists in leaf or display error.
      let eligibleElection = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).filter(\Eligibility.electionID == election.id!).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Election"))
      //return [candidate]
      let candidates = Candidate.query(on: req).join(\Runner.candidateID, to: \Candidate.id).join(\Election.id, to: \Runner.electionID).filter(\Election.id == election.id).all()
      //return [party] (of candidates)
      let parties = Party.query(on: req).join(\Candidate.partyID, to: \Party.id).join(\Runner.candidateID, to: \Candidate.id).join(\Election.id, to: \Runner.electionID).filter(\Election.id == election.id).all()
      //let context = whatever.
      let context = BallotContext(meta: Meta(title: "Ballot | \(election.name)", isHelp: false, userLoggedIn: true), election: eligibleElection, candidates: candidates, parties: parties)
      return try req.view().render("ballot", context)
    }
  }
  
  func confirmHandler(_ req: Request) throws -> Future<View> {
    
    return try req.parameters.next(Election.self).flatMap(to: View.self) {
      election in
      return try req.parameters.next(Candidate.self).flatMap(to: View.self) {
        candidate in
        
        let user = try req.requireAuthenticated(Elector.self)
        let eligibleElection = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).filter(\Eligibility.electionID == election.id!).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Election"))
        let eligibleCandidate = Candidate.query(on: req).join(\Runner.candidateID, to: \Candidate.id).filter(\Runner.candidateID == candidate.id!).filter(\Runner.electionID == election.id!).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Candidate"))
        let party = Party.query(on: req).join(\Candidate.partyID, to: \Party.id).filter(\Candidate.id == candidate.id!).first().unwrap(or: Abort(.unauthorized, reason: "Party not found"))
        return try req.view().render("confirm", ConfirmContext(meta: Meta(title: "Confirmation", isHelp: false, userLoggedIn: true), election: eligibleElection, party: party, candidate: eligibleCandidate))
      }
    }
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
  func loginPostHandler(_ req: Request, loginData: LoginData) throws -> Future<Response> {
    let expectedCsrfToken = try req.session()["CSRF_TOKEN"]; try req.session()["CSRF_TOKEN"] = nil
    guard expectedCsrfToken == loginData.csrfToken else { throw Abort(.badRequest) }
    return Elector.authenticate(username: loginData.username, password: loginData.password, using: BCryptDigest(), on: req).map(to: Response.self) {
      elector in
      guard let elector = elector else { return req.redirect(to: "/login?error") }
      try req.authenticateSession(elector)
      return req.redirect(to: "/elections")
    }
  }
  
  //Log Out
  func logoutHandler(_ req: Request) throws -> Response {
    try req.unauthenticateSession(Elector.self)
    return req.redirect(to: "/")
  }
  
  //Cast Ballot
  func castBallotHandler(_ req: Request) throws -> Response {
    let ciphertext = try AES256GCM.encrypt("This will be encrypted", key: "Using this super secret key.", iv: "This will be the thing what the user uses to check the thing.")
    let _ = try AES256GCM.decrypt(ciphertext.ciphertext, key: "Using this super secret key", iv: "This will be the thing what the user uses to check the thing.", tag: ciphertext.tag).convert(to: String.self)
    guard let _ = try? BCrypt.hash("election id + elector id + candidate id") else { fatalError("Failed to create Elector.") }
      //AES128.encrypt("vapor", key: "secret")
    //let aes = try AES(key: "passwordpassword", iv: "drowssapdrowssap") // aes128
    //let ciphertext = try aes.encrypt(Array("Nullam quis risus eget urna mollis ornare vel eu leo.".utf8))
    return req.redirect(to: "/")
  }
  
  //Preload
  
  func preloadHandler(_ req: Request, data: PreloadDataHolder) throws -> PreloadDataHolder {
    for electionCategory in data.preload.electionCategories {
      _ = ElectionCategory(name: electionCategory.name, startDate: electionCategory.startDate, endDate: electionCategory.endDate).save(on: req)
    }
    for party in data.preload.parties {
      _ = Party(name: party.name).save(on: req)
    }
    for elector in data.preload.electorate {
      _ = Elector(name: elector.name, username: elector.username, password: elector.password).save(on: req)
    }
    for candidate in data.preload.candidates {
      _ = Party.query(on: req).group(.or) { or in or.filter(\.name == candidate.partyName)}.first().map(to: Party.self) {party in
        _ = Candidate(name: candidate.name, partyID: party!.id!).save(on: req)
        return party!
      }
    }
    for election in data.preload.elections {
      _ = ElectionCategory.query(on: req).group(.or) { or in or.filter(\.name == election.electionCategoryName)}.first().map(to: ElectionCategory.self) { electionCategory in
        _ = Election(name: election.name, electionCategoryID: electionCategory!.id!).save(on: req)
        return electionCategory!
      }
    }
    for eligibility in data.preload.eligibilities {
      _ = Elector.query(on: req).group(.or) { or in or.filter(\.username == eligibility.electorUsername)}.first().map(to: Elector.self) { elector in
        _ = Election.query(on: req).group(.or) { or in or.filter(\.name == eligibility.electionName)}.first().map(to: Election.self) { election in
          _ = Eligibility(electorID: elector!.id!, electionID: election!.id!).save(on: req)
          return election!
        }
        return elector!
      }
    }
    for runner in data.preload.runners {
      _ = Candidate.query(on: req).group(.or) { or in or.filter(\.name == runner.candidateName)}.first().map(to: Candidate.self) { candidate in
        _ = Election.query(on: req).group(.or) { or in or.filter(\.name == runner.electionName)}.first().map(to: Election.self) { election in
          _ = Runner(candidateID: candidate!.id!, electionID: election!.id!).save(on: req)
          return election!
        }
        return candidate!
      }
    }
    return data
  }
  /*
  func preloadHandler(_ req: Request, data: PreloadDataHolder) throws -> Future<ElectionCategory> {
    let electionCategory = ElectionCategory(name: data.preloadData.electionCategories[0].name, startDate: data.preloadData.electionCategories[0].startDate, endDate: data.preloadData.electionCategories[0].endDate)
    return electionCategory.save(on: req)
    
  }
 */
  
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
  let csrfToken: String
}

struct ElectionsContext: Encodable {
  let meta: Meta
  let name: String
  let elections: Future<[Election]>
  let electionCategories: Future<[ElectionCategory]>
}

struct BallotContext: Encodable {
  let meta: Meta
  let election: Future<Election>
  let candidates: Future<[Candidate]>
  let parties: Future<[Party]>
}

struct ConfirmContext:Encodable {
  let meta: Meta
  let election: Future<Election>
  let party: Future<Party>
  let candidate: Future<Candidate>
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
struct LoginData: Content {
  let username: String
  let password: String
  let csrfToken: String
}

//Preload Data
struct PreloadDataHolder: Content {
  var preload: PreloadData
  
  struct PreloadData: Content {
    var electionCategories: [ElectionCategoriesPreload]
    var parties: [PartiesPreload]
    var electorate: [ElectoratePreload]
    var candidates: [CandidatesPreload]
    var elections: [ElectionsPreload]
    var eligibilities: [EligibilitiesPreload]
    var runners: [RunnersPreload]
    
    struct ElectionCategoriesPreload: Content { var name, startDate, endDate: String }
    struct PartiesPreload: Content { var name: String }
    struct ElectoratePreload: Content { var name, username, password: String }
    struct CandidatesPreload: Content { var name, partyName: String }
    struct ElectionsPreload: Content { var name, electionCategoryName: String }
    struct EligibilitiesPreload: Content { var electorUsername, electionName: String }
    struct RunnersPreload: Content { var electionName, candidateName: String }
  }
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
