import Vapor
import Fluent

struct ResultsController: RouteCollection {
    func boot(router: Router) throws {
        
        let resultsRoutes = router.grouped("api", "results")
        
        //create
        resultsRoutes.post(Result.self, use: createHandler)
        //retreive
        resultsRoutes.get(use: getAllHandler)
        //update
        resultsRoutes.put(Result.parameter, use: updateHandler)
        //delete
        resultsRoutes.delete(Result.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, result:Result) throws -> Future<Result> {
        return result.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Result]> {
        return Result.query(on: req).all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Result> {
        return try flatMap(to: Result.self, req.parameters.next(Result.self), req.content.decode(Result.self)){
            result, updatedResult in
            result.electionID = updatedResult.electionID
            result.candidateID = updatedResult.candidateID
            result.voteCount = updatedResult.voteCount
            return result.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Result.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
