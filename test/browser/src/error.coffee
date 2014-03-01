# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

error = _.error

describe "inherited Error", ->

  TestError = null
  testError = null

  beforeEach ->
    TestError = error "TestErrorName"
    try
      throw new TestError "TestErrorMessage"
    catch testError

  it "throws", ->
    (expect -> throw new TestError "TestErrorMessage").toThrow()

  it "has expected name and message", ->
    (expect testError.name).toBe "TestErrorName"
    (expect testError.message).toBe "TestErrorMessage"

  it "works with instanceof", ->
    (expect testError instanceof Error).toBe true
    (expect testError instanceof TestError).toBe true

  it "returns expected result from toString()", ->
    (expect testError.toString()).toBe "TestErrorName: TestErrorMessage"

  it "has the expected line number in the stack", ->
    stack = testError.stack
    if stack?
      (expect stack).toEqual jasmine.any String
      regExp = /ut1lSpec\.js:(\d*)[^\d]/
      match = regExp.exec stack
      (expect match).not.toBeNull()
      (expect match).toEqual jasmine.any Array
      (expect match.length).toBe 2
      line = +match[1]
      (expect line).toBe 15 # set JavaScript line number where TestError is thrown

  it "behaves expected for empty name argument", ->
    TestError = error()
    try
      throw new TestError("TestErrorMessage")
    catch testError
    (expect testError.name).not.toBeDefined()
    (expect testError.message).toBe "TestErrorMessage"
    (expect testError.toString()).toBe "Error: TestErrorMessage"
    try
      throw new TestError()
    catch testError
    (expect testError.name).not.toBeDefined()
    (expect testError.message).not.toBeDefined()
    (expect testError.toString()).toBe "Error"

  it "behaves expected for empty message argument", ->
    try
      throw new TestError()
    catch testError
    (expect testError.message).not.toBeDefined()
    (expect testError.toString()).toBe "TestErrorName"