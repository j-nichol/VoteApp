import Vapor
import Fluent
import Crypto
import Authentication

struct ElectorateController: RouteCollection {
  func boot(router: Router) throws {
    
    let electorateRoutes = router.grouped("api", "electorate")
  
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    
    let tokenAuthGroup = electorateRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    
  
    //create
    tokenAuthGroup.post(Elector.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Elector.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Elector.parameter, use: deleteHandler)
    //get ballots
    tokenAuthGroup.get(Elector.parameter, "ballots", use: getBallotsHandler)
    //get eligibilties
    tokenAuthGroup.get(Elector.parameter, "eligibilities", use: getEligibilitiesHandler)
    
  }
  
  ///create
  func createHandler(_ req: Request, elector:Elector) throws -> Future<Elector.Public> {
    let elector = Elector(name: elector.name, username: elector.username, password: elector.password)
    return elector.save(on: req).convertToPublic()
  }
  
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Elector.Public]> {
    return Elector.query(on: req).decode(data: Elector.Public.self).all()
  }
  
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Elector.Public]> {
    guard let searchTerm = req.query[UUID.self, at: "id"] else { throw Abort(.badRequest) }
    return Elector.query(on: req).decode(data: Elector.Public.self).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  
  ///update
  //figure out how to use Type.update(on: req)
  func updateHandler(_ req: Request) throws -> Future<Elector> {
    return try flatMap(to: Elector.self, req.parameters.next(Elector.self), req.content.decode(Elector.self)){
      elector, updatedElector in
      let newElector = Elector(name: updatedElector.name, username: updatedElector.username, password: updatedElector.password)
      elector.username = newElector.username
      elector.password = newElector.password
      elector.name = newElector.name
      return elector.update(on: req) //may need to revert to save(on:)
    }
  }
  
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Elector.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  
  ///get Ballots
  func getBallotsHandler(_ req: Request) throws -> Future<[Ballot]> {
    return try req.parameters.next(Elector.self).flatMap(to: [Ballot].self) {
      elector in try elector.ballots.query(on: req).all()
    }
  }
  
  ///get eligibilties
  func getEligibilitiesHandler(_ req: Request) throws -> Future<[Eligibility]> {
    return try req.parameters.next(Elector.self).flatMap(to: [Eligibility].self) {
      elector in try elector.eligibilities.query(on: req).all()
    }
  }
    
}
