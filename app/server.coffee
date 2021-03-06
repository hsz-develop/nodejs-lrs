express = require 'express'
passport = require 'passport'
routes = require './routes'
DBController = require './model/database/db_controller'
logger = require './logger'
AccessTokenMapper = require './model/access_token_mapper'
ClientMapper = require './model/client_mapper'
RequestTokenMapper = require './model/request_token_mapper'
UserMapper = require './model/user_mapper'
OAuthStrategies = require './auth/strategies'
OAuth = require './auth/oauth'

# Main class for launching the server.
# Only instanciate me once.
#
module.exports = class Server

  # stores all the methods available for the given route
  methods: {}

  # Launches the learning record store.
  #
  # @param @config
  #   the @configuration object, for details
  #   take a look at `config.coffee`
  #
  # @param callback
  #   Will be called as soon as the server is started
  #   or an error occured (first parameter).
  #   If no error occured one can assume a valid database
  #   connection and listening HTTP server.
  #
  constructor: (@config, callback = ->) ->
    logger.info "Let the magic happen."

    @express = express()
    @express.set 'view engine', 'ejs'
    @express.set 'views', './app/auth/views'
    @express.use express.logger stream:
      write: (message) -> logger.info message

    @express.use express.cookieParser()
    # bodyParser is still required for passport
    # hopefully getting fixed soon
    # @express.use express.urlencoded()
    # @express.use express.json()
    @express.use express.bodyParser()

    @express.use (req, res, next) =>
      if req.method is 'OPTIONS'
        res.header 'Access-Control-Allow-Origin', '*'
        res.header 'Access-Control-Allow-Methods', @methods[req.path]
        res.header 'Access-Control-Allow-Headers',
          'Authorization, Content-Type, X-Experience-API-Version, X-Experience-API-Consistent-Through'
        res.header 'X-Experience-API-Version', @config.server.xApiVersion
      next()

    # FIXME: Not exactly a secret
    @express.use express.session { secret: 'keyboard cat' }

    @express.use passport.initialize()
    @express.use passport.session()
    # @express.use @express.router
    @express.use express.errorHandler
      dumpExceptions: true
      showStack: true

    # initialize user routes
    user = require './auth/user'
    @express.get '/login', user.loginForm
    @express.post '/login', user.login
    @express.get '/logout', user.logout
    @express.get '/account', user.account

    @dbController = new DBController @config.database, (dbErr) =>
      if dbErr
        callback dbErr
      else
        @_createControllers (createErr) =>
          if createErr
            callback createErr
          else
            @_registerRoutes @controllers, (registerErr) =>
              if registerErr
                callback registerErr
              else if @config.server.port
                @express.listen @config.server.port, (listenErr) =>
                  if listenErr
                    callback listenErr, @
                  else
                    logger.info "server is listening on port #{config.server.port}..."
                    callback undefined, @
              else
                callback undefined, @

        @_initOAuth (createErr) =>
          if createErr
            callback createErr

  # Read all routes in the file `routes.coffee` and create all controllers.
  #
  # @private
  #
  _createControllers: (callback) ->
    logger.info "creat controllers:"
    @controllers = {}

    # lookup pathes and endpoints
    for url, route of routes
      for method, methodCallback of route
        [controllerName, methodName] = methodCallback.split '#'
        @controllers[controllerName] ?= {}
        @controllers[controllerName]['route'] ?= []
        routeInfo =
          url: "#{@config.server.routePrefix}/#{url}"
          method: method
          methodName: methodName
        @controllers[controllerName]['route'].push routeInfo

    counter = 0
    size = Object.keys(@controllers).length
    dbCon = @dbController

    # create controllers
    for name, dict of @controllers
      do(name, dict, dbCon, callback) ->
        dict['object'] = new (require "./controllers/#{name}") dbCon, (err) =>
          if err
            logger.error err
            callback(err)
          else
            logger.info "controller '#{name}' has been created"
            counter++
            if counter == size
              callback()

  # Join all the routes to the controllers
  #
  # @private
  #
  _registerRoutes: (controllers, callback) ->
    logger.info "registering API routes:"

    for name, dict of controllers
      controller = dict['object']
      logger.info "registering API endpoints for route: '#{name}':"

      for endpoint in dict['route']
        methodName = endpoint.methodName
        meth = endpoint.method.toUpperCase()
        @methods[endpoint.url] = if @methods[endpoint.url] then @methods[endpoint.url] + ", #{meth}" else meth
        logger.info "connect method: '#{endpoint.method}' to url: '#{endpoint.url}' and the method:'#{endpoint.methodName}'."
        @express[endpoint.method] endpoint.url, passport.authenticate 'token', { session: false } if @config.server.oauth
        @express[endpoint.method] endpoint.url, controller.before
        @express[endpoint.method] endpoint.url, do (controller, methodName) ->
          methods = controller[methodName]
          (params...) -> controller[methodName].apply(controller, params)

    callback()

  # Initializes the OAuth middleware if it's enabled in the configuration.
  #
  _initOAuth: (callback) =>
    if @config.server.oauth
      counter = 0
      mapperCreated = (err) =>
        counter++

        if counter == 4
          if err
            callback err
          else
            # initialise the OAuth middlewares for Passport
            new OAuthStrategies @accessTokenMapper, @clientMapper, @requestTokenMapper, @userMapper

            # set up the OAuth routes
            oauth = new OAuth @accessTokenMapper, @clientMapper, @requestTokenMapper, @userMapper
            @express.get @config.server.routePrefix+'/OAuth/authorize', oauth.createUserAuthorizationMiddleware()
            @express.post @config.server.routePrefix+'/OAuth/authorize', oauth.createUserDecisionMiddleware()
            @express.post @config.server.routePrefix+'/OAuth/initiate', oauth.createRequestTokenMiddleware()
            @express.post @config.server.routePrefix+'/OAuth/token', oauth.createAccessTokenMiddleware()

            callback()

      # create the OAuth related mappers
      @accessTokenMapper = new AccessTokenMapper @dbController, mapperCreated
      @clientMapper = new ClientMapper @dbController, mapperCreated
      @requestTokenMapper = new RequestTokenMapper @dbController, mapperCreated
      @userMapper = new UserMapper @dbController, mapperCreated

  # For getting the required server object when running supertest.
  #
  getRestServer: ->
    @express

  # For getting the required database controller when running supertest.
  #
  getDBController: ->
    @dbController
