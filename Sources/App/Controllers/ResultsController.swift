import Vapor
import Fluent

struct ResultsController: RouteCollection {
    func boot(router: Router) throws {
        
        let resultsRoutes = router.grouped("api", "results")
        
        //create
        resultsRoutes.post(Result.self, use: createHandler)
        //retrieve all
        resultsRoutes.get(use: getAllHandler)
        //retrieve specific
        resultsRoutes.get("search", use:searchHandler)
        //update
        resultsRoutes.put(Result.parameter, use: updateHandler)
        //delete
        resultsRoutes.delete(Result.parameter, use: deleteHandler)
        //get election
        resultsRoutes.get(Result.parameter, "election", use: getElectionHandler)
        //get candidate
        resultsRoutes.get(Result.parameter, "candidate", use: getCandidateHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, result:Result) throws -> Future<Result> {
        return result.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[Result]> {
        return Result.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[Result]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Result.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
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
    
    ///get election
    func getElectionHandler(_ req: Request) throws -> Future<Election> {
        return try req.parameters.next(Result.self).flatMap(to: Election.self) {
            result in result.election.get(on: req)
        }
    }
    
    ///get candidate
    func getCandidateHandler(_ req: Request) throws -> Future<Candidate> {
        return try req.parameters.next(Result.self).flatMap(to: Candidate.self) {
            result in result.candidate.get(on: req)
        }
    }
    
    
}
