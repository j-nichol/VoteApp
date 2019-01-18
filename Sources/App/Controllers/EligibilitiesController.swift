import Vapor
import Fluent

struct EligibilitiesController: RouteCollection {
    func boot(router: Router) throws {
        
        let eligibilitiesRoutes = router.grouped("api", "eligibilities")
        
        //create
        eligibilitiesRoutes.post(Eligibility.self, use: createHandler)
        //retrieve all
        eligibilitiesRoutes.get(use: getAllHandler)
        //retrieve specific
        eligibilitiesRoutes.get("search", use:searchHandler)
        //update
        eligibilitiesRoutes.put(Eligibility.parameter, use: updateHandler)
        //delete
        eligibilitiesRoutes.delete(Eligibility.parameter, use: deleteHandler)
        //get elector
        eligibilitiesRoutes.get(Eligibility.parameter, "elector", use: getElectorHandler)
        //get election
        eligibilitiesRoutes.get(Eligibility.parameter, "election", use: getElectionHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, eligibility:Eligibility) throws -> Future<Eligibility> {
        return eligibility.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[Eligibility]> {
        return Eligibility.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[Eligibility]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Eligibility.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Eligibility> {
        return try flatMap(to: Eligibility.self, req.parameters.next(Eligibility.self), req.content.decode(Eligibility.self)){
            eligibility, updatedEligibility in
            eligibility.electorID = updatedEligibility.electorID
            eligibility.electionID = updatedEligibility.electionID
            return eligibility.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Eligibility.self).delete(on: req).transform(to: HTTPStatus.ok)
    }
    
    ///get Elector
    func getElectorHandler(_ req: Request) throws -> Future<Elector> {
        return try req.parameters.next(Eligibility.self).flatMap(to: Elector.self) {
            eligibility in eligibility.elector.get(on: req)
        }
    }
    
    ///get Election
    func getElectionHandler(_ req: Request) throws -> Future<Election> {
        return try req.parameters.next(Eligibility.self).flatMap(to: Election.self) {
            eligibility in eligibility.election.get(on: req)
        }
    }
    
    
}
