assert = require "assert"
Validator = require "../../../../app/validator/validator.coffee"

val = new Validator 'app/validator/schemas/'

invalid = (err, done) ->
  if err?
    done()
  else
    done(new Error "Should not be valid")

invalidAgent =
  isEmpty: {}
  isAccount:
    homePageMissing: 
      "account": 
        "name": "1625378"
    nameMissing: 
      "account": 
        "homePage": "http://www.asmple.com"
  isOpenID:
    isEmpty:
      "openid":"" 
    isInvalid:
      "openid":"test&*(^&*^@&#^&^@" 
  isMbox:
    isEmpty:
      "mbox":""
    isInvalid:
      "mbox":"mailasdasdasdto:mail@example.com"
  isMboxSha1sum:
    isEmpty:
      "mbox_sha1sum":""
    isInvalidHash:
      "mbox_sha1sum":"c1e62d41da353afdd69"
  hasMultiple:
    "openid":"http://my.openid.test/12345678-1234-5678" 
    "mbox":"mailto:mail@example.com"
  withOptional:
    invalidObjectType:
      "objectType" : "Dude"
      "mbox":"mailto:mail@example.com"
    weirdProperty:
      "foo" : "bar"
      "mbox":"mailto:mail@example.com"
    
describe 'Agent', ->

  describe 'is empty', ->
    it 'should be invalid', (done) ->
      val.validateWithSchema invalidAgent.isEmpty, "Agent", (err) ->
        invalid err, done

  describe 'is account', ->
    describe 'name missing', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isAccount.nameMissing, "Agent", (err) ->
          invalid err, done
    describe 'homepage missing', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isAccount.homePageMissing, "Agent", (err) ->
          invalid err, done

  describe 'is openid', ->
    describe 'empty', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isOpenID.isEmpty, "Agent", (err) ->
          invalid err, done
    describe 'invalid url', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isOpenID.isInvalid, "Agent", (err) ->
          invalid err, done

  describe 'is mbox', ->
    describe 'empty', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isMbox.isEmpty, "Agent", (err) ->
          invalid err, done
    describe 'invalid url', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isMbox.isInvalid, "Agent", (err) ->
          invalid err, done
    describe "with optional field `objectType` unequal to `Agent`", -> 
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.withOptional.invalidObjectType, "Agent", (err) ->
          invalid err, done
    describe "with additional property", -> 
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.withOptional.weirdProperty, "Agent", (err) ->
          invalid err, done
    
  describe 'is mbox_sha1sum', ->
    describe 'empty', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isMboxSha1sum.isEmpty, "Agent", (err) ->
          invalid err, done
    describe 'invalid url', ->
      it 'should be invalid', (done) ->
        val.validateWithSchema invalidAgent.isMboxSha1sum.isInvalidHash, "Agent", (err) ->
          invalid err, done

  describe 'has mixed properties', ->
    it 'should be invalid', (done) ->
      val.validateWithSchema invalidAgent.hasMultiple, "Agent", (err) ->
        invalid err, done