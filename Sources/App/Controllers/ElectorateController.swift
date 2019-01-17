import Vapor
import Fluent

struct ElectorateController: RouteCollection {
    func boot(router: Router) throws {
        
        let electorateRoutes = router.grouped("api", "electorate")
        
        //create
        electorateRoutes.post(Elector.self, use: createHandler)
        //retrieve all
        electorateRoutes.get(use: getAllHandler)
        //retrieve specific
        electorateRoutes.get("search", use:searchHandler)
        //update
        electorateRoutes.put(Elector.parameter, use: updateHandler)
        //delete
        electorateRoutes.delete(Elector.parameter, use: deleteHandler)
        //get ballots
        electorateRoutes.get(Elector.parameter, "ballots", use: getBallotsHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, elector:Elector) throws -> Future<Elector> {
        return elector.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[Elector]> {
        return Elector.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[Elector]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Elector.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Elector> {
        return try flatMap(to: Elector.self, req.parameters.next(Elector.self), req.content.decode(Elector.self)){
            elector, updatedElector in
            elector.username = updatedElector.username
            elector.password = updatedElector.password
            elector.name = updatedElector.name
            return elector.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Elector.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    ///get Ballots
    func getBallotsHandler(_ req: Request) throws -> Future<[Ballot]> {
        return try req
            .parameters.next(Elector.self)
            .flatMap(to: [Ballot].self) { elector in
                try elector.ballots.query(on: req).all()
        }
    }
    
}
