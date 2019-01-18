import Vapor
import Fluent

struct PartiesController: RouteCollection {
    func boot(router: Router) throws {
        
        let partiesRoutes = router.grouped("api", "parties")
        
        //create
        partiesRoutes.post(Party.self, use: createHandler)
        //retrieve all
        partiesRoutes.get(use: getAllHandler)
        //retrieve specific
        partiesRoutes.get("search", use:searchHandler)
        //update
        partiesRoutes.put(Party.parameter, use: updateHandler)
        //delete
        partiesRoutes.delete(Party.parameter, use: deleteHandler)
        //get candidates
        partiesRoutes.get(Party.parameter, "candidates", use: getCandidatesHandler)
        
        
        
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
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Party> {
        return try flatMap(to: Party.self, req.parameters.next(Party.self), req.content.decode(Party.self)){
            party, updatedParty in
            party.name = updatedParty.name
            return party.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Party.self).delete(on: req).transform(to: HTTPStatus.ok)
    }
    
    //get candidates
    func getCandidatesHandler(_ req: Request) throws -> Future<[Candidate]> {
        return try req.parameters.next(Party.self).flatMap(to: [Candidate].self) {
            party in try party.candidates.query(on: req).all()
        }
    }
    
    
}
