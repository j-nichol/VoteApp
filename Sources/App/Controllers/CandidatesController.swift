import Vapor
import Fluent

struct CandidatesController: RouteCollection {
    func boot(router: Router) throws {
        
        let candidatesRoutes = router.grouped("api", "candidates")
        
        //create
        candidatesRoutes.post(Candidate.self, use: createHandler)
        //retrieve all
        candidatesRoutes.get(use: getAllHandler)
        //retrieve specific
        candidatesRoutes.get("search", use: searchHandler)
        //update
        candidatesRoutes.put(Candidate.parameter, use: updateHandler)
        //delete
        candidatesRoutes.delete(Candidate.parameter, use: deleteHandler)
        //get elector
        candidatesRoutes.get(Candidate.parameter, "party", use: getPartyHandler)
        //get results
        candidatesRoutes.get(Candidate.parameter, "results", use: getResultsHandler)
        //get runners
        candidatesRoutes.get(Candidate.parameter, "runners", use: getRunnersHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, candidate:Candidate) throws -> Future<Candidate> {
        return candidate.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[Candidate]> {
        return Candidate.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[Candidate]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Candidate.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
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
    
    ///get party
    func getPartyHandler(_ req: Request) throws -> Future<Party> {
        return try req.parameters.next(Candidate.self).flatMap(to: Party.self) {
            candidate in candidate.party.get(on: req)
        }
    }
    
    ///get results
    func getResultsHandler(_ req: Request) throws -> Future<[Result]> {
        return try req.parameters.next(Candidate.self).flatMap(to: [Result].self) {
            candidate in try candidate.results.query(on: req).all()
        }
    }
    
    ///get runners
    func getRunnersHandler(_ req: Request) throws -> Future<[Runner]> {
        return try req.parameters.next(Candidate.self).flatMap(to: [Runner].self) {
            candidate in try candidate.runners.query(on: req).all()
        }
    }
    
    
    
    
    
}
