import Vapor
import Fluent

struct BallotsController: RouteCollection {
    func boot(router: Router) throws {
        
        let ballotsRoutes = router.grouped("api", "ballots")
        
        //create
        ballotsRoutes.post(Ballot.self, use: createHandler)
        //retreive
        ballotsRoutes.get(use: getAllHandler)
        //retreive specific
        ballotsRoutes.get("search", use:searchHandler)
        //update
        ballotsRoutes.put(Ballot.parameter, use: updateHandler)
        //delete
        ballotsRoutes.delete(Ballot.parameter, use: deleteHandler)

    }
    
    ///create
    func createHandler(_ req: Request, ballot:Ballot) throws -> Future<Ballot> {
        return ballot.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Ballot]> {
        return Ballot.query(on: req).all()
    }
    /*
    func findHandler(_ req: Request) throws -> Future<Ballot> {
        let result =  Ballot.find(try req.parameters.next(Int.self), on: req)
        return result
    }
    */
    
    func searchHandler(_ req: Request) throws -> Future<[Ballot]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Ballot.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
    }
    
    
    /*
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
    }
     */
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Ballot> {
        return try flatMap(to: Ballot.self, req.parameters.next(Ballot.self), req.content.decode(Ballot.self)){
            ballot, updatedBallot in
            ballot.electorateID = updatedBallot.electorateID
            ballot.encryptedBallot = updatedBallot.encryptedBallot
            ballot.ballotChecker = updatedBallot.ballotChecker
            return ballot.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Ballot.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    

}
