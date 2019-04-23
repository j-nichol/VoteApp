import Vapor
import Fluent
import Crypto
import Authentication

struct BallotsController: RouteCollection {
  func boot(router: Router) throws {
    
    let ballotsRoutes = router.grouped("api", "ballots")
    
    //verify
    ballotsRoutes.post(VerifyData.self, at: "verify",  use: verifyHandler)
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = ballotsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    //create
    tokenAuthGroup.post(Ballot.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Ballot.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Ballot.parameter, use: deleteHandler)
  }
  
  ///create
  func createHandler(_ req: Request, ballot:Ballot) throws -> Future<Ballot> {
    return ballot.save(on: req)
  }
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Ballot]> {
    return Ballot.query(on: req).all()
  }
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Ballot]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Ballot.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  ///update
  func updateHandler(_ req: Request) throws -> Future<Ballot> {
    return try flatMap(to: Ballot.self, req.parameters.next(Ballot.self), req.content.decode(Ballot.self)){
      ballot, updatedBallot in
      ballot.ballotChecker = updatedBallot.ballotChecker
      ballot.encryptedBallotData = updatedBallot.encryptedBallotData
      ballot.encryptedBallotTag = updatedBallot.encryptedBallotTag
      ballot.ballotInitialisationVector = updatedBallot.ballotInitialisationVector
      return ballot.update(on: req)
    }
  }
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Ballot.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  ///verify
  func verifyHandler(_ req: Request, data: VerifyData) throws -> PassData {
    let testString = "\(data.election) \(data.username) \(data.candidate)"
    let hashString = "$2b$12$\(data.hash)"
    let pass = try BCrypt.verify(testString, created: hashString)
    let passData = PassData(pass: pass)
    return passData
  }
}

struct VerifyData: Content {
  let hash: String
  let username: String
  let election: Int
  let candidate: Int
}

struct PassData: Content {
  let pass: Bool
}
