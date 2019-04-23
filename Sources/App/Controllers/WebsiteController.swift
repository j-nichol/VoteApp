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
    
    let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<Elector>(path: "/login"))
    protectedRoutes.get("elections", use: electionsHandler)
    protectedRoutes.get("ballot", Election.parameter, use: ballotHandler)
    protectedRoutes.get("confirm", Election.parameter, Candidate.parameter, use: confirmHandler)
    protectedRoutes.post(CreateBallotData.self, at:  "cast", "ballot", use: castBallotHandler)
  }
  
///GETs
  //Index
  func indexHandler(_ req: Request) throws -> Future<View> {
    if (try req.isAuthenticated(Elector.self)) {
      return try electionsHandler(_: req)
    }
    return try req.view().render("index", IndexContext(meta: Meta(title: "Welcome", userLoggedIn: try req.isAuthenticated(Elector.self))))
  }
  
  //Login
  func loginHandler(_ req: Request) throws -> Future<View> {
    if (try req.isAuthenticated(Elector.self)) {
      return try electionsHandler(_: req)
    }
    let csrfToken = try CryptoRandom().generateData(count: 16).base64EncodedString()
    try req.session()["CSRF_TOKEN"] = csrfToken
    if (try req.isAuthenticated(Elector.self)) { return try electionsHandler(_: req) } else {return try req.view().render("login", LoginContext(meta: Meta(title: "Log In", userLoggedIn: false), loginError: (req.query[Bool.self, at: "error"] != nil), csrfToken: csrfToken))}
  }
  
  //Elections
  func electionsHandler(_ req: Request) throws -> Future<View> {
    let user = try req.requireAuthenticated(Elector.self)
    let verificationCode = try req.session()["VerificationCode"]; try req.session()["VerificationCode"] = nil

    let elections = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).filter(\Eligibility.hasVoted == false).all()
    let electionCategories = ElectionCategory.query(on: req).join(\Election.electionCategoryID, to: \ElectionCategory.id).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).all()
    
    return try req.view().render("elections", ElectionsContext(meta: Meta(title: "Elections", userLoggedIn: try req.isAuthenticated(Elector.self)), name: user.name, voteSuccesful: (req.query[Bool.self, at: "voteSuccesful"] != nil), elections: elections, electionCategories: electionCategories, verificationCode: verificationCode))
  }
  
  //Ballot
  func ballotHandler(_ req: Request) throws -> Future<View> {
    return try req.parameters.next(Election.self).flatMap(to: View.self) {
      election in
      
      let user = try req.requireAuthenticated(Elector.self)
      //check eligible. If so return election //must check exists in leaf or display error.
      let eligibleElection = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).filter(\Eligibility.electionID == election.id!).filter(\Eligibility.hasVoted == false).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Election"))
      //return [candidate]
      let candidates = Candidate.query(on: req).join(\Runner.candidateID, to: \Candidate.id).join(\Election.id, to: \Runner.electionID).filter(\Election.id == election.id).all()
      //return [party] (of candidates)
      let parties = Party.query(on: req).join(\Candidate.partyID, to: \Party.id).join(\Runner.candidateID, to: \Candidate.id).join(\Election.id, to: \Runner.electionID).filter(\Election.id == election.id).all()
      //let context = ...
      let context = BallotContext(meta: Meta(title: "Ballot", userLoggedIn: true), election: eligibleElection, candidates: candidates, parties: parties)
      return try req.view().render("ballot", context)
    }
  }
  
  //Confirmation
  func confirmHandler(_ req: Request) throws -> Future<View> {
    
    return try req.parameters.next(Election.self).flatMap(to: View.self) {
      election in
      return try req.parameters.next(Candidate.self).flatMap(to: View.self) {
        candidate in
        
        let user = try req.requireAuthenticated(Elector.self)
        let eligibleElection = Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == user.id!).filter(\Eligibility.electionID == election.id!).filter(\Eligibility.hasVoted == false).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Election"))
        let eligibleCandidate = Candidate.query(on: req).join(\Runner.candidateID, to: \Candidate.id).filter(\Runner.candidateID == candidate.id!).filter(\Runner.electionID == election.id!).first().unwrap(or: Abort(.unauthorized, reason: "Invalid Candidate"))
        let party = Party.query(on: req).join(\Candidate.partyID, to: \Party.id).filter(\Candidate.id == candidate.id!).first().unwrap(or: Abort(.unauthorized, reason: "Party not found"))
        
        let verificationCodeText = "\(election.id ?? -1) \(user.username) \(candidate.id ?? -1)"
        guard var verificationCodeHash = try? BCrypt.hash(verificationCodeText) else { fatalError("Failed to create verification code.") }
        verificationCodeHash = String(verificationCodeHash.dropFirst(7))
        try req.session()["VerificationCode"] = verificationCodeHash
        
        let verificationURL = verificationCodeHash.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let context = ConfirmContext(meta: Meta(title: "Confirmation", userLoggedIn: true), name: user.name, election: eligibleElection, party: party, candidate: eligibleCandidate, verificationCode: verificationCodeHash, verificationURL: verificationURL ?? "")
        
        return try req.view().render("confirm", context)
      }
    }
  }
  
///POSTs
  //Log In
  func loginPostHandler(_ req: Request, loginData: LoginData) throws -> Future<Response> {
    if (try req.isAuthenticated(Elector.self)) {
      return req.future().map() {
        return req.redirect(to: "/elections")
      }
    }
    
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
  func castBallotHandler(_ req: Request, data: CreateBallotData) throws -> Future<Response> {
    
    let electionID = data.electionID
    let candidateID = data.candidateID
    let elector = try req.requireAuthenticated(Elector.self)
    
    //check eligibility
    let electorEligibility = Eligibility.query(on: req).filter(\.electionID == electionID).filter(\.electorID == elector.id!).filter(\.hasVoted == false).first().unwrap(or: Abort(.unauthorized, reason:  "User ineligible to vote in this election"))
    let _ = Runner.query(on: req).filter(\.electionID == electionID).filter(\.candidateID == candidateID).first().unwrap(or: Abort(.unauthorized, reason: "Invalid ballot"))

    let plaintext = "In the election with ID: \(electionID), candidate with id: \(candidateID) recieved a vote."
    let key = "An Incredibly secret password!!1"
    let iv = String((0...11).map{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
    let cipherText = try AES256GCM.encrypt(plaintext, key: key, iv: iv)
    let ballotCheckerHash = try req.session()["VerificationCode"];
    let testString = "\(electionID) \(elector.username) \(candidateID)"
    let hashString = "$2b$12$\(ballotCheckerHash!)"
    let pass = try BCrypt.verify(testString, created: hashString)
    
    if (!pass) {throw Abort(.badRequest, reason: "Invalid Verification Code recieved.")}
  
    let ballot = Ballot(ballotChecker: ballotCheckerHash!, encryptedBallotData: cipherText.ciphertext, encryptedBallotTag: cipherText.tag, ballotInitialisationVector: iv)
    
    return req.transaction(on: .psql) { conn in
      return ballot.save(on: req).flatMap(to: Response.self) {
        ballot in
        /// Flat-map the future string to a future response
        return electorEligibility.flatMap(to: Response.self) {
          eligibility in
          eligibility.hasVoted = true
          
          return eligibility.update(on: req).map(to: Response.self) {
            newEligibility in
            return req.redirect(to: "/elections?voteSuccesful")
          }
        }
      }
    }
  }
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
  let voteSuccesful: Bool
  let elections: Future<[Election]>
  let electionCategories: Future<[ElectionCategory]>
  let verificationCode: String?
}

struct BallotContext: Encodable {
  let meta: Meta
  let election: Future<Election>
  let candidates: Future<[Candidate]>
  let parties: Future<[Party]>
}

struct ConfirmContext:Encodable {
  let meta: Meta
  let name: String
  let election: Future<Election>
  let party: Future<Party>
  let candidate: Future<Candidate>
  let verificationCode: String
  let verificationURL: String
}

/// Data Types

//Page Meta
struct Meta: Content {
  let title: String
  let userLoggedIn: Bool
}

//Login Data
struct LoginData: Content {
  let username: String
  let password: String
  let csrfToken: String
}

//BallotCreationData
struct CreateBallotData: Content {
    let electionID: Int
    let candidateID: Int
}
