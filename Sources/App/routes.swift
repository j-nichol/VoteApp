import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // Basic "It works" example
  router.get { req in
    return "200: OK"
  }

  /*
  let acronymsController = AcronymsController()
  let usersController = UsersController()
  try router.register(collection: acronymsController)
  try router.register(collection: usersController)
   */

  let adminsController = AdminsController()
  let ballotsController = BallotsController()
  let candidatesController = CandidatesController()
  let electionCategoriesController = ElectionCategoriesController()
  let electionsController = ElectionsController()
  let electorateController = ElectorateController()
  let eligibilitiesController = EligibilitiesController()
  let partiesController = PartiesController()
  let resultsController = ResultsController()
  let runnersController = RunnersController()
  let websiteController = WebsiteController()
  
  try router.register(collection: adminsController)
  try router.register(collection: ballotsController)
  try router.register(collection: candidatesController)
  try router.register(collection: electionCategoriesController)
  try router.register(collection: electionsController)
  try router.register(collection: electorateController)
  try router.register(collection: eligibilitiesController)
  try router.register(collection: partiesController)
  try router.register(collection: resultsController)
  try router.register(collection: runnersController)
  try router.register(collection: websiteController)
    
}
