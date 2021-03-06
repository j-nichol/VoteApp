import Vapor
import Fluent
import Crypto
import Authentication

struct ResultsController: RouteCollection {
  func boot(router: Router) throws {
    
    let resultsRoutes = router.grouped("api", "results")
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = resultsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
  
    //create
    tokenAuthGroup.post(Result.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Result.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Result.parameter, use: deleteHandler)
    //get election
    tokenAuthGroup.get(Result.parameter, "election", use: getElectionHandler)
    //get candidate
    tokenAuthGroup.get(Result.parameter, "candidate", use: getCandidateHandler)
  }
  
  ///create
  func createHandler(_ req: Request, result:Result) throws -> Future<Result> {
    return result.save(on: req)
  }
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Result]> {
    return Result.query(on: req).all()
  }
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Result]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Result.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  ///update
  func updateHandler(_ req: Request) throws -> Future<Result> {
    return try flatMap(to: Result.self, req.parameters.next(Result.self), req.content.decode(Result.self)){
      result, updatedResult in
      result.electionID = updatedResult.electionID
      result.candidateID = updatedResult.candidateID
      result.voteCount = updatedResult.voteCount
      return result.update(on: req)
    }
  }
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Result.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  ///get election
  func getElectionHandler(_ req: Request) throws -> Future<Election> {
    return try req.parameters.next(Result.self).flatMap(to: Election.self) {
      result in result.election.get(on: req)
    }
  }
  ///get candidate
  func getCandidateHandler(_ req: Request) throws -> Future<Candidate> {
    return try req.parameters.next(Result.self).flatMap(to: Candidate.self) {
      result in result.candidate.get(on: req)
    }
  }
}
