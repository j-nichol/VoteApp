import Vapor
import Fluent

struct ElectorateController: RouteCollection {
    func boot(router: Router) throws {
        
        let electorateRoutes = router.grouped("api", "electorate")
        
        //create
        electorateRoutes.post(Elector.self, use: createHandler)
        //retrieve
        electorateRoutes.get(use: getAllHandler)
        //update
        electorateRoutes.put(Elector.parameter, use: updateHandler)
        //delete
        electorateRoutes.delete(Elector.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, elector:Elector) throws -> Future<Elector> {
        return elector.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Elector]> {
        return Elector.query(on: req).all()
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
    
    
}
