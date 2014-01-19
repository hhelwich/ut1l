_ = require "../src/obj"

describe "Object utils", ->

  describe "createConstructor()", ->

    it "creates a new empty object with given prototype", ->
      proto = a: 123
      obj = do (_.creator proto)
      # validate
      (expect obj).not.toBe proto
      (expect obj.a).toBe 123
      proto.a = 456
      (expect obj.a).toBe 456

    it "creates a new object with given prototype and constructor", ->
      proto = a: 123
      construct = (@b) ->
      obj = (_.creator proto, construct) 456
      # validate
      (expect obj.a).toBe 123
      (expect obj.b).toBe 456

    it "adds optional stuff to constructor", ->
      stuff =
        a: ->
        b: 3
      constr = _.creator {}, (->), stuff
      # validate
      for foo of stuff
        (expect constr[foo]).toBe stuff[foo]

    it "uses constructor return value if truthy", ->
      foo = { bla: 42 }
      constr = _.creator {}, -> foo
      # validate
      obj = constr()
      (expect obj).toBe foo

    it "can be called with no protoype", ->
      f = (a, b) -> a + b
      foo = { bla: 42 }
      constr = _.creator null, f, foo
      # validate
      # constr should be a clone of f
      (expect constr).not.toBe f
      (expect constr).not.toBe foo
      (expect constr 2, 3).toBe 5
      # should been extended with foo
      (expect constr.bla).toBe 42
      (expect f.bla).not.toBeDefined()
