import Vapor
import Fluent

struct EligibilitiesController: RouteCollection {
    func boot(router: Router) throws {
        
        let eligibilitiesRoutes = router.grouped("api", "eligibilities")
        
        //create
        eligibilitiesRoutes.post(Eligibility.self, use: createHandler)
        //retreive
        eligibilitiesRoutes.get(use: getAllHandler)
        //update
        eligibilitiesRoutes.put(Eligibility.parameter, use: updateHandler)
        //delete
        eligibilitiesRoutes.delete(Eligibility.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, eligibility:Eligibility) throws -> Future<Eligibility> {
        return eligibility.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Eligibility]> {
        return Eligibility.query(on: req).all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Eligibility> {
        return try flatMap(to: Eligibility.self, req.parameters.next(Eligibility.self), req.content.decode(Eligibility.self)){
            eligibility, updatedEligibility in
            eligibility.electorateID = updatedEligibility.electorateID
            eligibility.electionID = updatedEligibility.electionID
            return eligibility.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Eligibility.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
