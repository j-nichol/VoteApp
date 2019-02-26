import Vapor
import Fluent
import Crypto
import Authentication

struct CandidatesController: RouteCollection {
  func boot(router: Router) throws {
    
    let candidatesRoutes = router.grouped("api", "candidates")
    candidatesRoutes.get("election", Election.parameter, use: getAllInElectionHandler)
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = candidatesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    //create
    tokenAuthGroup.post(Candidate.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use: searchHandler)
    //update
    tokenAuthGroup.put(Candidate.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Candidate.parameter, use: deleteHandler)
    //get elector
    tokenAuthGroup.get(Candidate.parameter, "party", use: getPartyHandler)
    //get results
    tokenAuthGroup.get(Candidate.parameter, "results", use: getResultsHandler)
    //get runners
    tokenAuthGroup.get(Candidate.parameter, "runners", use: getRunnersHandler)
    
  }
  
  ///create
  func createHandler(_ req: Request, candidate:Candidate) throws -> Future<Candidate> {
    return candidate.save(on: req)
  }
  
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Candidate]> {
    return Candidate.query(on: req).all()
  }
  
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Candidate]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Candidate.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  
  ///update
  //figure out how to use Type.update(on: req)
  func updateHandler(_ req: Request) throws -> Future<Candidate> {
    return try flatMap(to: Candidate.self, req.parameters.next(Candidate.self), req.content.decode(Candidate.self)){
      candidate, updatedCandidate in
      candidate.name = updatedCandidate.name
      candidate.partyID = updatedCandidate.partyID
      return candidate.update(on: req) //may need to revert to save(on:)
    }
  }
  
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Candidate.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  
  ///get party
  func getPartyHandler(_ req: Request) throws -> Future<Party> {
    return try req.parameters.next(Candidate.self).flatMap(to: Party.self) {
      candidate in candidate.party.get(on: req)
    }
  }
  
  ///get results
  func getResultsHandler(_ req: Request) throws -> Future<[Result]> {
    return try req.parameters.next(Candidate.self).flatMap(to: [Result].self) {
      candidate in try candidate.results.query(on: req).all()
    }
  }
  
  ///get runners
  func getRunnersHandler(_ req: Request) throws -> Future<[Runner]> {
    return try req.parameters.next(Candidate.self).flatMap(to: [Runner].self) {
      candidate in try candidate.runners.query(on: req).all()
    }
  }
  
  ///get allInElection
  func getAllInElectionHandler(_ req: Request) throws -> Future<[Candidate]> {
    return try req.parameters.next(Election.self).flatMap(to: [Candidate].self){
      election in
      return Candidate.query(on: req).join(\Runner.candidateID, to: \Candidate.id).join(\Election.id, to: \Runner.electionID).filter(\Election.id == election.id).all()
    }
  }
}
