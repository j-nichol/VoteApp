import Vapor
import Fluent

struct CandidatesController: RouteCollection {
    func boot(router: Router) throws {
        
        let candidatesRoutes = router.grouped("api", "candidates")
        
        //create
        candidatesRoutes.post(Candidate.self, use: createHandler)
        //retreive
        candidatesRoutes.get(use: getAllHandler)
        //update
        candidatesRoutes.put(Candidate.parameter, use: updateHandler)
        //delete
        candidatesRoutes.delete(Candidate.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, candidate:Candidate) throws -> Future<Candidate> {
        return candidate.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Candidate]> {
        return Candidate.query(on: req).all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Candidate> {
        return try flatMap(to: Candidate.self, req.parameters.next(Candidate.self), req.content.decode(Candidate.self)){
            candidate, updatedCandidate in
            candidate.name = updatedCandidate.name
            candidate.partyID = updatedCandidate.partyID
            return candidate.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Candidate.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
