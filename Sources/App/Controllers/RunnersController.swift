import Vapor
import Fluent
import Crypto
import Authentication

struct RunnersController: RouteCollection {
  func boot(router: Router) throws {
    
    let runnersRoutes = router.grouped("api", "runners")
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = runnersRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    //create
    tokenAuthGroup.post(Runner.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Runner.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Runner.parameter, use: deleteHandler)
    //get candidate
    tokenAuthGroup.get(Runner.parameter, "candidate", use: getCandidateHandler)
    //get election
    tokenAuthGroup.get(Runner.parameter, "election", use: getElectionHandler)
    
  }
  
  ///create
  func createHandler(_ req: Request, runner:Runner) throws -> Future<Runner> {
    return runner.save(on: req)
  }
  
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Runner]> {
    return Runner.query(on: req).all()
  }
  
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Runner]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Runner.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  
  ///update
  //figure out how to use Type.update(on: req)
  func updateHandler(_ req: Request) throws -> Future<Runner> {
    return try flatMap(to: Runner.self, req.parameters.next(Runner.self), req.content.decode(Runner.self)){
      runner, updatedRunner in
      runner.candidateID = updatedRunner.candidateID
      runner.electionID = updatedRunner.electionID
      return runner.update(on: req) //may need to revert to save(on:)
    }
  }
  
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Runner.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  
  ///get candidate
  func getCandidateHandler(_ req: Request) throws -> Future<Candidate> {
    return try req.parameters.next(Runner.self).flatMap(to: Candidate.self) {
      runner in runner.candidate.get(on: req)
    }
  }
  
  ///get election
  func getElectionHandler(_ req: Request) throws -> Future<Election> {
    return try req.parameters.next(Runner.self).flatMap(to: Election.self) {
      runner in runner.election.get(on: req)
    }
  }
    
}
