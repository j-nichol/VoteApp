import Vapor
import Fluent

struct ElectionCategoriesController: RouteCollection {
    func boot(router: Router) throws {
        
        let electionCategoriesRoutes = router.grouped("api", "electionCategories")
        
        //create
        electionCategoriesRoutes.post(ElectionCategory.self, use: createHandler)
        //retreive
        electionCategoriesRoutes.get(use: getAllHandler)
        //update
        electionCategoriesRoutes.put(ElectionCategory.parameter, use: updateHandler)
        //delete
        electionCategoriesRoutes.delete(ElectionCategory.parameter, use: deleteHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, electionCategory:ElectionCategory) throws -> Future<ElectionCategory> {
        return electionCategory.save(on: req)
    }
    
    ///retrieve
    func getAllHandler(_ req: Request) throws -> Future<[ElectionCategory]> {
        return ElectionCategory.query(on: req).all()
    }
    
    ///update
    //figure out how to use Type.update(on: req)
    func updateHandler(_ req: Request) throws -> Future<ElectionCategory> {
        return try flatMap(to: ElectionCategory.self, req.parameters.next(ElectionCategory.self), req.content.decode(ElectionCategory.self)){
            electionCategory, updatedElectionCategory in
            electionCategory.name = updatedElectionCategory.name
            electionCategory.startDate = updatedElectionCategory.startDate
            electionCategory.endDate = updatedElectionCategory.endDate
            return electionCategory.update(on: req) //may need to revert to save(on:)
        }
    }
    
    ///delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(ElectionCategory.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    
}
