import FluentPostgreSQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  /// Register providers first
  try services.register(FluentPostgreSQLProvider())
  try services.register(LeafProvider())

  /// Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)

  /// Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  services.register(middlewares)

  /// Configure database
  var databases = DatabasesConfig()
  let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
  let username = Environment.get("DATABASE_USER") ?? "vapor"
  let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
  let password = Environment.get("DATABASE_PASSWORD") ?? "password"
  let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, username: username, database: databaseName, password: password)
  

  /// Register the configured SQLite database to the database config.
  let database = PostgreSQLDatabase(config: databaseConfig)
  databases.add(database: database, as: .psql)
  services.register(databases)

  /// Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: ElectionCategory.self, database: .psql)
  migrations.add(model: Party.self, database: .psql)
  migrations.add(model: Elector.self, database: .psql)
  migrations.add(model: Ballot.self, database: .psql)
  migrations.add(model: Candidate.self, database: .psql)
  migrations.add(model: Election.self, database: .psql)
  migrations.add(model: Eligibility.self, database: .psql)
  migrations.add(model: Result.self, database: .psql)
  migrations.add(model: Runner.self, database: .psql)
  services.register(migrations)
  
  ///Configure Fluent application commands
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
  
  ///Configure Leaf
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)

}
