# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

O = _.create.object

describe "Object", ->

  describe "Builder", ->

    it "creates a new empty object with given prototype", ->
      proto = a: 123
      obj = do (O proto)
      # validate
      (expect obj).not.toBe proto
      (expect obj.a).toBe 123
      proto.a = 456
      (expect obj.a).toBe 456

    it "creates a new object with given prototype and constructor", ->
      proto = a: 123
      construct = (@b) ->
      obj = (O proto, construct) 456
      # validate
      (expect obj.a).toBe 123
      (expect obj.b).toBe 456

    it "adds optional stuff to constructor", ->
      stuff =
        a: ->
        b: 3
      constr = O {}, (->), stuff
      # validate
      for foo of stuff
        (expect constr[foo]).toBe stuff[foo]

    it "uses constructor return value if truthy", ->
      foo = { bla: 42 }
      constr = O {}, -> foo
      # validate
      obj = constr()
      (expect obj).toBe foo

    it "can be called with no protoype", ->
      f = (a, b) ->
        @result = a + b
      foo = { bla: 42 }
      constr = O f, foo
      # validate
      # constr should be a clone of f
      (expect (constr 2, 3).result).toBe 5
      # should been extended with foo
      (expect constr.bla).toBe 42
      # instanceof should work
      (expect (constr 2, 3) instanceof constr).toBe true

    it "works with instanceof", ->
      builder = O {}, ->
      inst = builder()
      # validate
      (expect inst instanceof builder).toBe true

    it "works with inherited instanceofs", ->
      builder = O {}, ->
      subbuilder = O builder(), ->
      inst1 = builder()
      inst2 = subbuilder()
      (expect inst1 instanceof builder).toBe true
      (expect inst1 instanceof subbuilder).toBe false
      (expect inst2 instanceof builder).toBe true
      (expect inst2 instanceof subbuilder).toBe true
