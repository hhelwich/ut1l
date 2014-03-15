require "./console"

if (new Error()).stack?
  console.log "INFO: Interpreter supports error stacks"
else
  console.log "INFO: Interpreter does not support error stacks"

isOpera = opera? and opera.toString() == "[object Opera]"
if isOpera
  console.log "WARN: skip error stack line number check in opera" # line numbers in opera 11/12 are bullshit. why?


# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

error = _.error

getStackLine = (stack) ->
  (expect stack).toEqual jasmine.any String
  regExp = /ut1lSpec\.js:(\d*)[^\d]/
  match = regExp.exec stack
  (expect match).not.toBeNull()
  (expect match).toEqual jasmine.any Array
  (expect match.length).toBe 2
  +match[1]


describe "Error builder", ->

  myErrorBuilder = null

  beforeEach ->
    myErrorBuilder = error "MyError"


  it "works with empty name argument", ->
    myErrorBuilder = error()
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
    mySubErrorBuilder = error "MySubError", myErrorBuilder
    try
      throw mySubErrorBuilder "My sub error cause"
    catch e
      (expect e.message).toBe "My sub error cause"
      (expect e.name).toBe "MySubError"
      (expect e instanceof mySubErrorBuilder).toBe true
      (expect e instanceof myErrorBuilder).toBe true
      (expect e.toString()).toBe "MySubError: My sub error cause"
      if e.stack? and not isOpera
        (expect getStackLine e.stack).toBe 82 # set JavaScript line number where mySubError is thrown


  describe "returned error object", ->

    myError = null

    beforeEach ->
      try
        throw myErrorBuilder "My error cause"
      catch myError


    it "has expected name and message", ->
      (expect myError.name).toBe "MyError"
      (expect myError.message).toBe "My error cause"

    it "works with instanceof", ->
      (expect myError instanceof myErrorBuilder).toBe true

    it "returns expected result from toString()", ->
      (expect myError.toString()).toBe "MyError: My error cause"

    it "has the expected line number in the stack", ->
      if myError.stack? and not isOpera
        (expect getStackLine myError.stack).toBe 100 # set JavaScript line number where myError is thrown

describe "c4tch()", ->

  notANumber = error "NotANumber"
  onerror = (e) ->
    (expect e).toBeDefined()
    (expect e instanceof notANumber).toBe true
    42

  it "catches a specific error", ->
    action = (n, d) ->
      if (d != 0)
        n / d
      else
        throw notANumber("Oh no!")
    newaction = notANumber.c4tch action, onerror
    (expect newaction 2, 3).toBe 2 / 3
    (expect newaction 2, 0).toBe 42

  it "also catches sub errors", ->
    divisionByNegativZero = error "DivisionByNegativZero", notANumber
    action = -> throw divisionByNegativZero()
    newaction = notANumber.c4tch action, onerror
    (expect newaction 2, 0).toBe 42

  it "does not catch other errors", ->
    syntaxError = error "SyntaxError"
    action = -> throw syntaxError()
    newaction = notANumber.c4tch action, onerror
    (expect (-> newaction 2, 0)).toThrow()

  it "preserves 'this' in action function", ->
    obj =
      foo: notANumber.c4tch ->
        (expect @).toBe obj
    obj.foo()

  it "preserves 'this' in error handler", ->
    obj =
      foo: notANumber.c4tch (-> throw notANumber()), ->
        (expect @).toBe obj
    obj.foo()
