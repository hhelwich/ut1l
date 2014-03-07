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
      (expect e.name).not.toBeDefined()
      (expect e.message).toBe "My error cause"
      (expect e.toString()).toBe "Error: My error cause"
    try
      throw myErrorBuilder()
    catch e
      (expect e.name).not.toBeDefined()
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
      (expect e instanceof Error).toBe true
      (expect e.toString()).toBe "MySubError: My sub error cause"
      if e.stack?
        (expect getStackLine e.stack).toBe 59 # set JavaScript line number where mySubError is thrown


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
      (expect myError instanceof Error).toBe true
      (expect myError instanceof myErrorBuilder).toBe true

    it "returns expected result from toString()", ->
      (expect myError.toString()).toBe "MyError: My error cause"

    it "has the expected line number in the stack", ->
      if myError.stack?
        (expect getStackLine myError.stack).toBe 78 # set JavaScript line number where myError is thrown
