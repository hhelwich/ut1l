# Return a function which creates a new object with the given prototype and initializes this object with the given
# constructor function (if given).
# Also copy optional `extend` object content to returned function.

isFunction = (func) ->
  typeof func == "function"

defineProperty = Object.defineProperty

adaptProperties = do ->
  if isFunction defineProperty
    c1 =
      writable:     false
      enumerable:   false
      configurable: false
    c2 =
      enumerable:   false
      configurable: false
    c3 =
      configurable: false
    (obj) ->
      for own prop of obj
        if prop.length > 0 and (prop.charAt 0) == "_"
          if prop.length >= 2 and (prop.charAt 1) == "_"
            defineProperty obj, prop, c1
          else
            defineProperty obj, prop, c2
        else
          defineProperty obj, prop, c3
      return
  else
    ->


createBuilder = (extend, constructor, prototype) ->
  if isFunction extend # first argument is missing => shift arguments
    prototype = constructor
    constructor = extend
    extend = null
  else if not constructor? and not prototype?
    prototype = extend
    extend = null
  F = if constructor?
    # Create function which forwards to given constructor function
    (args) ->
      ret = constructor.apply @, args
      if ret != undefined then ret else @ # if constructor returns not undefined value: use it instead of object
  else
    ->
  if prototype?
    adaptProperties prototype
  else
    prototype = {}
  # Set functions prototype field.
  F.prototype = prototype
  # Create function which creates a new object with the given prototype and initializes with the given constructor.
  f = -> new F arguments
  f.prototype = prototype # for instanceof
  # Add static fields to function.
  for key, value of extend # no need to check with hasOwnProperty() as Function.prototype inherits Object.prototype
    f[key] = value
  f

module.exports = createBuilder
