module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-nodemon'

  rep = if process.env.TRAVIS? then 'spec' else 'dot'

  grunt.initConfig
    mochaTest:
      unit:
        options:
          reporter: rep
        src: ['test/unit/**/*.coffee']
      functional:
        options:
          reporter: rep
        src: ['test/functional/statements/**/*.coffee']
      integration:
        options:
          reporter: rep
        src: ['test/integration/**/*.coffee']

    nodemon:
      dev:
        options:
          file: 'app/main.coffee'

  grunt.registerTask 'default', 'Launch the server using nodemon', ['nodemon']

  grunt.registerTask 'doc', 'Generate codo documentation', ->
    require 'codo/lib/codo'
    cmd = require 'codo/lib/command'
    cmd.run()

  grunt.registerTask 'users', ['users:list']

  grunt.registerTask 'users:list', ->
    done = @async()

    initUserMapper (err, mapper) ->
      mapper.getAll (err, users) ->
        for user in users
          grunt.log.writeln "#{user.value.id}\t#{user.value.username}"
        done()

  grunt.registerTask 'users:add', ->
    done = @async()

    initUserMapper (err, mapper) ->
      if err
        console.log 'unable to create the user'
        done false
      else
        username = grunt.option 'name'
        password = grunt.option 'pw'
        if username == undefined || password == undefined
          console.error 'need username and password to add a user'
          done false
        user =
          username: username
          password: password
        mapper.save user, (err, createdUser) ->
          if err
            console.log err
            done false
          else
            done()

  grunt.registerTask 'users:remove', ->
    users = require './app/auth/database/users'
    if grunt.option('name')
      users.remove(grunt.option('name'))
    else if grunt.option('all')
      users.removeAll()

  grunt.registerTask 'users:help', ->
    grunt.log.writeln 'users:add [-name] [-pw] [-file]'
    grunt.log.writeln 'users:remove [-name]'
    grunt.log.writeln 'users:list'
    
  grunt.registerTask 'addSampleStatements', ->
    DBController = require './app/model/database/db_controller'
    StatementMapper = require './app/model/statement_mapper'
    fs = require 'fs'
    config = require './app/config'
    logger = require './app/logger'
      
    statementPath = './test/data/1.0.0/valid/statement/different-verbs/'
      
    done = @async()
    
    dbc = new DBController config.database, (err) ->
      if err
        grunt.log.writeln err
        done()
      else
        sm = new StatementMapper dbc, (err) ->
          if err
            grunt.log.writeln err
            done err
          else
            fs.readdir statementPath, (err, files) ->
              if err
                grunt.log.writeln err
                done err
              else
                unless files?.length
                  grunt.log.writeln 'no statements found!'
                  done()
                else 
                  i = 0
                  a = 0
                  for file in files
                    sm.save require(statementPath + file), (err) ->
                      
                      if err
                        grunt.log.writeln err
                      else
                        a++
                        grunt.log.writeln "added statement #{file}"
                      
                      console.log files.length
                      console.log i
                      
                      if ++i is files.length
                        grunt.log.writeln "#{a} statements successfully added!"
                        done()
                        
# Initialises the user mapper.
#
# Grunt tasks using this function directly or indirectly must run asynchronously
# since Cradle performs asynchronous HTTP HEAD requests to check whether or not
# the database is available.
#
initUserMapper = (callback) ->
  initDbController (err, dbController) ->
    if err
      callback err
    else
      UserMapper = require './app/model/user_mapper'
      @userMapper = new UserMapper dbController, (err) =>
        if err
          callback err
        else
          callback null, @userMapper

# Initialises the database controller.
#
# Grunt tasks using this function directly or indirectly must run asynchronously
# since Cradle performs asynchronous HTTP HEAD requests to check whether or not
# the database is available.
#
initDbController = (callback) ->
  config = require './app/config'
  DBController = require './app/model/database/db_controller'

  @dbController = new DBController config.database, (err) =>
    if err
      callback err, @dbController
    else
      callback null, @dbController