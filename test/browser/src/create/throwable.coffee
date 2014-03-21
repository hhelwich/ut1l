log = require "../console"

if (new Error()).stack?
  log "Interpreter supports error stacks"
else
  log "Interpreter does not support error stacks"

isOpera = opera? and opera.toString() == "[object Opera]"
if isOpera
  log "skip error stack line number check in opera" # line numbers in opera 11/12 are bullshit. why?


# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

T = _.create.throwable

getStackLine = (stack) ->
  (expect stack).toEqual jasmine.any String
  regExp = /ut1lSpec\.js:(\d*)[^\d]/
  match = regExp.exec stack
  (expect match).not.toBeNull()
  (expect match).toEqual jasmine.any Array
  (expect match.length).toBe 2
  +match[1]


describe "Throwable", ->

  describe "Builder", ->

    myErrorBuilder = null

    beforeEach ->
      myErrorBuilder = T "MyError"


    it "works with empty name argument", ->
      myErrorBuilder = T()
      try
        throw myErrorBuilder("My error cause")
      catch e
        (expect e.name).toBe "Error"
        (expect e.message).toBe "My error cause"
        (expect e.toString()).toBe "Error: My error cause"
      try
        throw myErrorBuilder()
      catch e
        (expect e.name).toBe "Error"
        (expect e.message).not.toBeDefined()
        (expect e.toString()).toBe "Error"

    it "works with empty message argument", ->
      try
        throw myErrorBuilder()
      catch e
        (expect e.message).not.toBeDefined()
        (expect e.toString()).toBe "MyError"

    it "can be used with parent builder", ->
      mySubErrorBuilder = T "MySubError", myErrorBuilder
      try
        throw mySubErrorBuilder "My sub error cause"
      catch e
        (expect e.message).toBe "My sub error cause"
        (expect e.name).toBe "MySubError"
        (expect e instanceof mySubErrorBuilder).toBe true
        (expect e instanceof myErrorBuilder).toBe true
        (expect e.toString()).toBe "MySubError: My sub error cause"
        if e.stack? and not isOpera
          log e.stack.substring 0, Math.min e.stack.length, 500
          (expect getStackLine e.stack).toBe 188 # set JavaScript line number where mySubError is thrown


    describe "returned throwable", ->

      myError = null

      beforeEach ->
        try
          throw myErrorBuilder "My error cause"
        catch myError


      it "has expected name and message", ->
        (expect myError.name).toBe "MyError"
        (expect myError.message).toBe "My error cause"

      it "works with instanceof", ->
        createMySubError = T "MySubError", myErrorBuilder
        mySubError = createMySubError "Cause1"
        # verify
        (expect myError instanceof myErrorBuilder).toBe true
        (expect myError instanceof createMySubError).toBe false
        (expect mySubError instanceof myErrorBuilder).toBe true
        (expect mySubError instanceof createMySubError).toBe true

      it "returns expected result from toString()", ->
        (expect myError.toString()).toBe "MyError: My error cause"

      it "has the expected line number in the stack", ->
        if myError.stack? and not isOpera
          log myError.stack.substring 0, Math.min myError.stack.length, 500
          (expect getStackLine myError.stack).toBe 207 # set JavaScript line number where myError is thrown

  describe "c4tch()", ->

    createNotANumber = T "NotANumber"
    onerror = (e) ->
      (expect e).toBeDefined()
      (expect e instanceof createNotANumber).toBe true
      42

    it "catches a specific throwable", ->
      action = (n, d) ->
        if (d != 0)
          n / d
        else
          throw createNotANumber("Oh no!")
      newaction = T.c4tch createNotANumber, action, onerror
      (expect newaction 2, 3).toBe 2 / 3
      (expect newaction 2, 0).toBe 42

    it "also catches sub throwables", ->
      divisionByNegativZero = T "DivisionByNegativZero", createNotANumber
      action = -> throw divisionByNegativZero()
      newaction = T.c4tch createNotANumber, action, onerror
      (expect newaction 2, 0).toBe 42

    it "does not catch other throwables", ->
      createSyntaxError = T "SyntaxError"
      action = -> throw createSyntaxError "Cause"
      fail = -> (expect true).toBe false
      newaction = T.c4tch createNotANumber, action, fail
      (expect (-> newaction 2, 0)).toThrow()

    it "catches all throwables if no constructor is given", ->
      onerrorCount = 0
      createSyntaxError = T "SyntaxError"
      action = -> throw createSyntaxError "Cause"
      onerror = -> onerrorCount += 1
      newaction = T.c4tch action, onerror
      (expect newaction 2, 0).toBe 1

    it "does not catch differently created values", ->
      newaction = T.c4tch (-> throw new Error()), ->
      (expect (-> newaction())).toThrow()
      newaction = T.c4tch (-> throw "foo"), ->
      (expect (-> newaction())).toThrow()

    it "preserves 'this' in action function", ->
      obj =
        foo: T.c4tch createNotANumber, ->
          (expect @).toBe obj
      obj.foo()

    it "preserves 'this' in throwable handler", ->
      obj =
        foo: T.c4tch createNotANumber, (-> throw createNotANumber()), ->
          (expect @).toBe obj
      obj.foo()
