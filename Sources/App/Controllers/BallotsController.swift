import Vapor
import Fluent

struct BallotsController: RouteCollection {
    func boot(router: Router) throws {
        
        let ballotsRoutes = router.grouped("api", "ballots")
        
        //create
        ballotsRoutes.post(Ballot.self, use: createHandler)
        //retrieve all
        ballotsRoutes.get(use: getAllHandler)
        //retrieve specific
        ballotsRoutes.get("search", use:searchHandler)
        //update
        ballotsRoutes.put(Ballot.parameter, use: updateHandler)
        //delete
        ballotsRoutes.delete(Ballot.parameter, use: deleteHandler)
        //get elector
        ballotsRoutes.get(Ballot.parameter, "elector", use: getElectorHandler)

    }
    
    ///create
    func createHandler(_ req: Request, ballot:Ballot) throws -> Future<Ballot> {
        return ballot.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[Ballot]> {
        return Ballot.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[Ballot]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return Ballot.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<Ballot> {
        return try flatMap(to: Ballot.self, req.parameters.next(Ballot.self), req.content.decode(Ballot.self)){
            ballot, updatedBallot in
            ballot.electorID = updatedBallot.electorID
            ballot.encryptedBallot = updatedBallot.encryptedBallot
            ballot.ballotChecker = updatedBallot.ballotChecker
            return ballot.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Ballot.self).delete(on: req).transform(to: HTTPStatus.ok)
    }
    
    ///get Elector
    func getElectorHandler(_ req: Request) throws -> Future<Elector> {
        return try req.parameters.next(Ballot.self).flatMap(to: Elector.self) {
            ballot in ballot.elector.get(on: req)
        }
    }
    

}
