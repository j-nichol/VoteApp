import Vapor
import Fluent
import Crypto
import Authentication

struct ElectionsController: RouteCollection {
  func boot(router: Router) throws {
  
    let electionsRoutes = router.grouped("api", "elections")
    
    electionsRoutes.get(use: getAllHandler)
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = electionsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
  
    //create
    tokenAuthGroup.post(Election.self, use: createHandler)
    //retrieve all
    //tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Election.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Election.parameter, use: deleteHandler)
    //get elector
    tokenAuthGroup.get(Election.parameter, "electionCategory", use: getElectionCategoryHandler)
    //get eligibilities
    tokenAuthGroup.get(Election.parameter, "eligibilities", use: getEligibilitiesHandler)
    //get results
    tokenAuthGroup.get(Election.parameter, "results", use: getResultsHandler)
    //get runners
    tokenAuthGroup.get(Election.parameter, "runners", use: getRunnersHandler)
    //test
    tokenAuthGroup.get("test", use: testHandler)
    
  }
  
  ///create
  func createHandler(_ req: Request, election:Election) throws -> Future<Election> {
    return election.save(on: req)
  }
  
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Election]> {
    return Election.query(on: req).all()
  }
  
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Election]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Election.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  
  ///update
  //figure out how to use Type.update(on: req)
  func updateHandler(_ req: Request) throws -> Future<Election> {
    return try flatMap(to: Election.self, req.parameters.next(Election.self), req.content.decode(Election.self)){
      election, updatedElection in
      election.name = updatedElection.name
      election.electionCategoryID = updatedElection.electionCategoryID
      return election.update(on: req) //may need to revert to save(on:)
    }
  }
  
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Election.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  
  //get electionCategory
  func getElectionCategoryHandler(_ req: Request) throws -> Future<ElectionCategory> {
    return try req.parameters.next(Election.self).flatMap(to: ElectionCategory.self) {
      election in election.electionCategory.get(on: req)
    }
  }
  
  //get eligibilities
  func getEligibilitiesHandler(_ req: Request) throws -> Future<[Eligibility]> {
    return try req.parameters.next(Election.self).flatMap(to: [Eligibility].self) {
      election in try election.eligibilities.query(on: req).all()
    }
  }
  //get results
  func getResultsHandler(_ req: Request) throws -> Future<[Result]> {
    return try req.parameters.next(Election.self).flatMap(to: [Result].self) {
      election in try election.results.query(on: req).all()
    }
  }
  //get runners
  func getRunnersHandler(_ req: Request) throws -> Future<[Runner]> {
    return try req.parameters.next(Election.self).flatMap(to: [Runner].self) {
      election in try election.runners.query(on: req).all()
    }
  }
  //test
  func testHandler(_ req: Request) throws -> Future<[Election]> {
    let uuid = UUID(uuidString: "6932927F-FE4E-4810-AFC5-CB003DD1F835")
    return Election.query(on: req).join(\Eligibility.electionID, to: \Election.id).filter(\Eligibility.electorID == uuid!).all()

  }
    
}
