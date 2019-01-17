import Vapor
import Fluent

struct ElectionsController: RouteCollection {
    func boot(router: Router) throws {
        
        let electionsRoutes = router.grouped("api", "elections")
        
        //create
        electionsRoutes.post(Election.self, use: createHandler)
        //retrieve all
        electionsRoutes.get(use: getAllHandler)
        //retrieve specific
        electionsRoutes.get("search", use:searchHandler)
        //update
        electionsRoutes.put(Election.parameter, use: updateHandler)
        //delete
        electionsRoutes.delete(Election.parameter, use: deleteHandler)
        
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
        return try req.parameters.next(Election.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
