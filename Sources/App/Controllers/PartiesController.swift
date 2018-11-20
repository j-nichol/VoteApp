import Vapor
import Fluent

struct PartiesController: RouteCollection {
    func boot(router: Router) throws {
        
        let partiesRoutes = router.grouped("api", "parties")
        
        //create
        partiesRoutes.post(Party.self, use: createHandler)
        //retreive
        partiesRoutes.get(use: getAllHandler)
        //update
        partiesRoutes.put(Party.parameter, use: updateHandler)
        //delete
        partiesRoutes.delete(Party.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, party:Party) throws -> Future<Party> {
        return party.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Party]> {
        return Party.query(on: req).all()
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
        return try req.parameters.next(Party.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
