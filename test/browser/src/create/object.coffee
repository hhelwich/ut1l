# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

log = require "../console"

O = _.create.object

describe "Object", ->

  describe "Builder", ->

    it "creates a new empty object with given prototype", ->
      proto = a: 123
      obj = (O proto)()
      # validate
      (expect obj).not.toBe proto
      (expect obj.a).toBe 123
      proto.a = 456
      (expect obj.a).toBe 456

    it "creates a new object with given prototype and constructor", ->
      proto = a: 123
      construct = (@b) ->
      obj = (O construct, proto) 456
      # validate
      (expect obj.a).toBe 123
      (expect obj.b).toBe 456

    it "adds optional stuff to constructor", ->
      stuff =
        a: ->
        b: 3
      constr = O stuff, (->), {}
      # validate
      for foo of stuff
        (expect constr[foo]).toBe stuff[foo]

    it "uses constructor return value if truthy", ->
      foo = { bla: 42 }
      constr = O (-> foo), {}
      # validate
      obj = constr()
      (expect obj).toBe foo

    it "can be called with no protoype", ->
      f = (a, b) ->
        @result = a + b
      foo = { bla: 42 }
      constr = O foo, f
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
      builder = O (->)
      subbuilder = O (->), builder()
      inst1 = builder()
      inst2 = subbuilder()
      (expect inst1 instanceof builder).toBe true
      (expect inst1 instanceof subbuilder).toBe false
      (expect inst2 instanceof builder).toBe true
      (expect inst2 instanceof subbuilder).toBe true


    describe "prototype properties", ->

      obj = null
      keys = null
      proto = null

      hasFeature = typeof Object.defineProperty == "function"
      if not hasFeature
        log "browser does not support unenumerable, unwriteable and undeletable properties"

      beforeEach ->
        # Create object with some prototype
        proto =
          pub: "foo"
          _noenum: "foo2"
          __nowrite: "foo3"
        keys = for own key of proto
          key
        obj = do O proto


      it "_ prefixed properties are not enumerable if possible", ->
        # Enumerate properties
        props = {} # Set of all enumerable properties
        for prop of obj
          props[prop] = null
        # Verify enumerable properties
        if hasFeature
          (expect props).toEqual
            pub: null
        else
          (expect props).toEqual
            pub: null
            _noenum: null
            __nowrite: null

      it "__ prefixed properties are not writable if possible", ->
        # Write all properties and check if changed
        props = {} # Set of all writable properties
        for prop in keys
          proto[prop] = 42
          if proto[prop] == 42
            props[prop] = null
        # Verify
        if hasFeature
          (expect props).toEqual
            pub: null
            _noenum: null
        else
          (expect props).toEqual
            pub: null
            _noenum: null
            __nowrite: null

      it "__ prefixed properties are not writable on object if possible", ->
        # Write all properties and check if changed
        props = {} # Set of all writable properties
        for prop in keys
          obj[prop] = 42
          if obj[prop] == 42
            props[prop] = null
        # Verify
        if hasFeature
          (expect props).toEqual
            pub: null
            _noenum: null
        else
          (expect props).toEqual
            pub: null
            _noenum: null
            __nowrite: null

      it "all properties are not deletable if possible", ->
        # Write all properties and check if changed
        props = {} # Set of all deletable properties
        for prop in keys
          delete proto[prop]
          if not proto.hasOwnProperty prop
            props[prop] = null
        # Verify
        if hasFeature
          (expect props).toEqual {}
        else
          (expect props).toEqual
            pub: null
            _noenum: null
            __nowrite: null
