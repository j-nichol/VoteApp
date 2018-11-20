import Vapor
import Fluent

struct BallotsController: RouteCollection {
    func boot(router: Router) throws {
        
        let ballotsRoutes = router.grouped("api", "ballots")
        
        //create
        ballotsRoutes.post(Ballot.self, use: createHandler)
        //retreive
        ballotsRoutes.get(use: getAllHandler)
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
