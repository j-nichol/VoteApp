import Vapor
import Fluent

struct RunnersController: RouteCollection {
    func boot(router: Router) throws {
        
        let runnersRoutes = router.grouped("api", "runners")
        
        //create
        runnersRoutes.post(Runner.self, use: createHandler)
        //retrieve all
        runnersRoutes.get(use: getAllHandler)
        //retrieve specific
        runnersRoutes.get("search", use:searchHandler)
        //update
        runnersRoutes.put(Runner.parameter, use: updateHandler)
        //delete
        runnersRoutes.delete(Runner.parameter, use: deleteHandler)
        
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
        return try req.parameters.next(Runner.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
