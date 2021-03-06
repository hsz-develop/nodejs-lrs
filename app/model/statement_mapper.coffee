Validator = require '../validator/validator'
logger = require '../logger'
_ = require 'underscore'
utils = require '../utils'
BaseMapper = require './base_mapper'

# Provides operations for all statements on top
# of couchDB.
#
module.exports = class StatementMapper extends BaseMapper

  @TYPE = 'statement'

  @VIEWS =
    find:
      map: (dox) ->
        if doc.type == 'statement'
          emit doc.value.id, doc.value
    findById:
      map: (doc) ->
        if doc.type == 'statement'
          emit doc.value.id, doc.value
    listIds:
      map: (doc) ->
        if doc.type == 'statement'
          emit doc.value.id, null
    count:
      map: (doc) ->
        if doc.type == 'statement'
          emit null, 1
      reduce: (key, values, rereduce) ->
        sum values
    findByAgent:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit doc.value.actor.openID, doc.value
          if doc.value.actor.mbox
            emit doc.value.actor.mbox.toString(), doc.value
          if doc.value.actor.mbox_sha1sum
            emit doc.value.actor.mbox_sha1sum, doc.value
          if doc.value.actor.account
            emit doc.value.actor.account.homePage, doc.value
    findByVerb:
      map: (doc) ->
        if doc.type == 'statement'
          emit doc.value.verb.id, doc.value
    findByActivity:
      map: (doc)->
        if doc.type == 'statement'
          emit doc.value.object.id, doc.value
    findByStored:
      map: (doc)->
        if doc.type == 'statement'
          emit doc.value.stored, doc.value
    findByAgentVerbActivity:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.verb.id, doc.value.object.id], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.verb.id, doc.value.object.id], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.verb.id, doc.value.object.id], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.verb.id, doc.value.object.id], doc.value
    findByAgentVerbActivityStored:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.verb.id, doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.verb.id, doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.verb.id, doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.verb.id, doc.value.object.id, doc.value.stored], doc.value
    findByAgentActivity:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.object.id], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.object.id], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.object.id], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.object.id], doc.value
    findByAgentActivityStored:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.object.id, doc.value.stored, doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.object.id, doc.value.stored], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.object.id, doc.value.stored], doc.value
    findByAgentVerb:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.verb.id], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.verb.id], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.verb.id], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.verb.id], doc.value
    findByAgentVerbStored:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.verb.id, doc.value.stored], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.verb.id, doc.value.stored], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.verb.id, doc.value.stored], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.verb.id, doc.value.stored], doc.value
    findByAgentStored:
      map: (doc) ->
        if doc.type == 'statement'
          if doc.value.actor.openID
            emit [doc.value.actor.openID, doc.value.stored], doc.value
          if doc.value.actor.mbox
            emit [doc.value.actor.mbox.toString(), doc.value.stored], doc.value
          if doc.value.actor.mbox_sha1sum
            emit [doc.value.actor.mbox_sha1sum, doc.value.stored], doc.value
          if doc.value.actor.account
            emit [doc.value.actor.account.homePage, doc.value.stored], doc.value
    findByVerbActivity:
      map: (doc) ->
        if doc.type == 'statement'
          emit [doc.value.verb.id, doc.value.object.id], doc.value
    findByVerbActivityStored:
      map: (doc) ->
        if doc.type == 'statement'
          emit [doc.value.verb.id, doc.value.object.id, doc.value.stored], doc.value
    findByVerbStored:
      map: (doc) ->
        if doc.type == 'statement'
          emit [doc.value.verb.id, doc.value.stored], doc.value
    findByActivityStored:
      map: (doc) ->
        if doc.type == 'statement'
          emit [doc.value.object.id, doc.value.stored], doc.value



  filterStatements: (filter, callback) ->
    startkey = []
    endkey = []
    viewMasterKey = ""

    if filter.agent
      startkey.push filter.agent
      endkey.push filter.agent
      viewMasterKey += 'agent|'

    if filter.verb
      viewMasterKey += 'verb|'
      startkey.push filter.verb
      endkey.push filter.verb

    if filter.activity
      viewMasterKey += 'activity|'
      startkey.push filter.object.id
      endkey.push filter.object.id

    if filter.since or filter.until
      viewMasterKey += 'stored|'
      if filter.since
        startkey.push filter.since
      if filter.until
        endkey.push filter.until

    descending = false
    if not filter.ascending
      #toggle start end endkey
      tmp = startkey
      startkey = endkey
      endkey = tmp
      descending = true

    options =
      limit:filter.limit
      skip:filter.skip
      descending: descending

    arrayEqual = (a, b) ->
      a.length is b.length and a.every (elem, i) -> elem is b[i]

    if arrayEqual startkey, endkey
      switch startkey.length
        when 0
          break
          # do nothing
        when 1
          options.key = startkey[0]
          break
        else
          options.key = startkey
          break
    else
      if startkey.length != 0
        options.startkey = startkey

      if endkey.length != 0
        options.endkey = endkey

    #console.log "Options"
    #console.log options
    #if viewMasterKey
    #console.log "viewMasterKey"
    #console.log viewMasterKey

    viewsSelection=
      'agent|verb|activity|stored|' : @views.findByAgentVerbActivityStored
      'agent|verb|activity|'        : @views.findByAgentVerbActivity
      'agent|verb|stored|'          : @views.findByAgentVerbStored
      'agent|verb|'                 : @views.findByAgentVerb
      'agent|activity|stored|'      : @views.findByAgentActivityStored
      'agent|activity|'             : @views.findByAgentActivity
      'agent|stored|'               : @views.findByAgentStored
      'agent|'                      : @views.findByAgent
      'verb|activity|stored|'       : @views.findByVerbActivityStored
      'verb|activity|'              : @views.findByVerbActivity
      'verb|stored|'                : @views.findByVerbStored
      'verb|'                       : @views.findByVerb
      'activity|stored|'            : @views.findByActivityStored
      'activity|'                   : @views.findByActivity
      'stored|'                     : @views.findByStored
      ''                            : @views.findByStored
    viewsSelection[viewMasterKey] options, callback


  # Instanciates a new statement mapper.
  #
  # @param dbController
  #  the database-controller to be used by this mapper
  #
  constructor: ->
    super
    @validator = new Validator 'app/validator/schemas/'

  # Returns all stored statements to the callback.
  #
  # TODO: one should be able to specify the maximum number of returned statements
  #
  getAll: (options, callback) ->
    filter = {}
    options.limit = options.limit ? 0
    # if limit is set to 0 use the server maximum
    options.limit = 1000 if options.limit == 0


    logger.info "limit is set to #{options.limit}."
    # if skip was defined start at skip+1, else start at the beginning
    options.skip = options.skip ? 0
    newSkip = 0

    logger.info "skip is set to #{options.skip}."

    @views.count (err, count) =>
      scount = 0
      if count.length == 0
        #there are no statements in the db
        callback undefined, []
        return
      else
        scount = count[0].value

      logger.info "#{scount} statements in the database."
      if options.skip > scount
        err = new Error 'More statements requested as there are! Illegal skip parameter!'
        err.httpCode = 400
        callback err
      else

        if options.skip + options.limit < scount
          newSkip = options.skip + options.limit

        @filterStatements options, (err, docs) =>
          if err
            logger.error "getALL: database access failed: #{JSON.stringify err}"
            callback err, []
          else
            #console.log "filterStatements done!"
            #console.log docs
            statements = []
            for doc in docs
              statements.push doc.value

            options.skip = newSkip
            callback undefined, statements, options

  # Returns the statement with the given id to the callback.
  #
  # @param id
  #   id of the statement to look up
  #
  find: (id, callback) ->
    @validator.validateWithSchema id, 'UUID', (err) =>
      if err
        err = new Error 'Invalid UUID supplied!'
        err.httpCode = 400
        callback err
      else
        @views.findById key: id, (err, docs) =>
          if err
            logger.error 'find statement: ' + id
            logger.error "find: database access with view find_statement_by/id failed: #{JSON.stringify err}"
            callback err, []
          else
            switch docs.length
              when 0
                logger.info 'statement does not exist: ' + id
                # there is no statement with the given id
                # TODO callback ERROR, null
                callback undefined
                break
              when 1
                logger.info 'statement found: ' + id
                # all right, one statement found
                statement = docs[0].value
                callback undefined, statement
                break
              else
                # should not happen, there are more
                # then one statements with the same id
                # TODO callback ERROR, null
                callback 'Multiple Statements for the same id found.'
                break
  # Saves this statement to the database
  # Tries to store this statement and if there
  # is no id, it generates an id, otherwise
  # it checks the two statements for equality
  #
  save: (statement, callback) ->

    @validator.validateWithSchema statement, "xAPIStatement", (validatorErr) =>
      if validatorErr
        err = new Error "Statement is invalid: #{validatorErr}"
        err.httpCode = 400
        callback err
      else
        unless statement.id?
          # No id is given, generate one
          statement.id = utils.generateUUID()
          logger.info 'generated statement id: ' + statement.id
          # Check if the given id is already in the database

        @find statement.id, (err, foundStatement) =>
          if err
            logger.error 'find returned error: ' + err
            # There is no statement with the given id,
            # the given statement will be inserted
            callback err
          else
            if foundStatement
              if _.isEqual statement, foundStatement
                # all right statement is already in the database
                callback undefined, statement
              else
                # conflict, there is a statement with the
                # same id but a different content
                err = new Error 'Conflicting statement: Found a statement with the same id but a different content!'
                err.httpCode = 409
                callback err
            else
              super statement, (err, res) =>
                callback err, statement

