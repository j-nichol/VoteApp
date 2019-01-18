import Vapor
import Fluent

struct ElectionCategoriesController: RouteCollection {
    func boot(router: Router) throws {
        
        let electionCategoriesRoutes = router.grouped("api", "electionCategories")
        
        //create
        electionCategoriesRoutes.post(ElectionCategory.self, use: createHandler)
        //retrieve all
        electionCategoriesRoutes.get(use: getAllHandler)
        //retrieve specific
        electionCategoriesRoutes.get("search", use:searchHandler)
        //update
        electionCategoriesRoutes.put(ElectionCategory.parameter, use: updateHandler)
        //delete
        electionCategoriesRoutes.delete(ElectionCategory.parameter, use: deleteHandler)
        //get elections
        electionCategoriesRoutes.get(ElectionCategory.parameter, "elections", use: getElectionsHandler)
        
    }
    
    ///create
    func createHandler(_ req: Request, electionCategory:ElectionCategory) throws -> Future<ElectionCategory> {
        return electionCategory.save(on: req)
    }
    
    ///retrieve all
    func getAllHandler(_ req: Request) throws -> Future<[ElectionCategory]> {
        return ElectionCategory.query(on: req).all()
    }
    
    ///retrieve specific
    func searchHandler(_ req: Request) throws -> Future<[ElectionCategory]> {
        guard let searchTerm = req.query[Int.self, at: "id"] else { throw Abort(.badRequest) }
        return ElectionCategory.query(on: req).group(.or) { or in
            or.filter(\.id == searchTerm)
            }.all()
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
        return try req.parameters.next(ElectionCategory.self).delete(on: req).transform(to: HTTPStatus.ok)
    }
    
    //get elections
    func getElectionsHandler(_ req: Request) throws -> Future<[Election]> {
        return try req.parameters.next(ElectionCategory.self).flatMap(to: [Election].self) {
            electionCategory in try electionCategory.elections.query(on: req).all()
        }
    }
    
}
