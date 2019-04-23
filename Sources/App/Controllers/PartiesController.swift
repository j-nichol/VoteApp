import Vapor
import Fluent
import Crypto
import Authentication

struct PartiesController: RouteCollection {
  func boot(router: Router) throws {
    
    let partiesRoutes = router.grouped("api", "parties")
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddleware = Admin.tokenAuthMiddleware()
    let tokenAuthGroup = partiesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
  
    //create
    tokenAuthGroup.post(Party.self, use: createHandler)
    //retrieve all
    tokenAuthGroup.get(use: getAllHandler)
    //retrieve specific
    tokenAuthGroup.get("search", use:searchHandler)
    //update
    tokenAuthGroup.put(Party.parameter, use: updateHandler)
    //delete
    tokenAuthGroup.delete(Party.parameter, use: deleteHandler)
    //get candidates
    tokenAuthGroup.get(Party.parameter, "candidates", use: getCandidatesHandler)
  }
  
  ///create
  func createHandler(_ req: Request, party:Party) throws -> Future<Party> {
    return party.save(on: req)
  }
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Party]> {
    return Party.query(on: req).all()
  }
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Party]> {
    guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
    return Party.query(on: req).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  ///update
  func updateHandler(_ req: Request) throws -> Future<Party> {
    return try flatMap(to: Party.self, req.parameters.next(Party.self), req.content.decode(Party.self)){
      party, updatedParty in
      party.name = updatedParty.name
      return party.update(on: req)
    }
  }
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Party.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  ///get candidates
  func getCandidatesHandler(_ req: Request) throws -> Future<[Candidate]> {
    return try req.parameters.next(Party.self).flatMap(to: [Candidate].self) {
      party in try party.candidates.query(on: req).all()
    }
  }
}
