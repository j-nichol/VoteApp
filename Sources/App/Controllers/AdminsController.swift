import Vapor
import Fluent
import Crypto
import Authentication

struct AdminsController: RouteCollection {
  func boot(router: Router) throws {
    
    let adminsRoutes = router.grouped("api", "admins")
    
    
    //create
    //adminsRoutes.post(AdminCreateData.self, use: createHandler)
    /*
    //retrieve all
    adminsRoutes.get(use: getAllHandler)
    //retrieve specific
    adminsRoutes.get("search", use:searchHandler)
    //update
    adminsRoutes.put(Admin.parameter, use: updateHandler)
    //delete
    adminsRoutes.delete(Admin.parameter, use: deleteHandler)
     */
    
    ///This bit's for token creation
    let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
    let basicAuthGroup = adminsRoutes.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)
    
    
    let guardAuthMiddleware = Admin.guardAuthMiddleware()
    let tokenAuthMiddlewear = Admin.tokenAuthMiddleware()
    
    let tokenAuthGroup = adminsRoutes.grouped(tokenAuthMiddlewear, guardAuthMiddleware)
    tokenAuthGroup.post(AdminCreateData.self, use: createHandler)
    tokenAuthGroup.get(use: getAllHandler)
    tokenAuthGroup.get("search", use: searchHandler)
    tokenAuthGroup.put(Admin.parameter, use: updateHandler)
    tokenAuthGroup.delete(Admin.parameter, use: deleteHandler)
    
    
  }
  
  ///create
  func createHandler(_ req: Request, data:AdminCreateData) throws -> Future<Admin.Public> {
    //let admin = try req.requireAuthenticated(Admin.self)
    let newAdmin = try Admin(username: data.username, password: BCrypt.hash(data.password))
    return newAdmin.save(on: req).convertToPublic()
  }
  
  ///retrieve all
  func getAllHandler(_ req: Request) throws -> Future<[Admin.Public]> {
    return Admin.query(on: req).decode(data: Admin.Public.self).all()
  }
  
  ///retrieve specific
  func searchHandler(_ req: Request) throws -> Future<[Admin.Public]> {
    guard let searchTerm = req.query[UUID.self, at: "id"] else { throw Abort(.badRequest) }
    return Admin.query(on: req).decode(data: Admin.Public.self).group(.or) { or in
      or.filter(\.id == searchTerm)
      }.all()
  }
  
  ///update
  //figure out how to use Type.update(on: req)
  func updateHandler(_ req: Request) throws -> Future<Admin> {
    return try flatMap(to: Admin.self, req.parameters.next(Admin.self), req.content.decode(AdminCreateData.self)){
      admin, updateData in
      admin.username = updateData.username
      admin.password = try BCrypt.hash(updateData.password)
      let admin = try req.requireAuthenticated(Admin.self)
      return admin.update(on: req) //may need to revert to save(on:)
    }
  }
  
  ///delete
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Admin.self).delete(on: req).transform(to: HTTPStatus.ok)
  }
  
  ///login
  func loginHandler(_ req: Request) throws -> Future<Token> {
    let admin =  try req.requireAuthenticated(Admin.self)
    let token = try Token.generate(for: admin)
    return  token.save(on: req)
  }
  
}

struct AdminCreateData: Content {
  let username: String
  let password: String
}
