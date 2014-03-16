# Return a function which creates a new object with the given prototype and initializes this object with the given
# constructor function (if given).
# Also copy optional `extend` object content to returned function.

createBuilder = (prototype, constructor, extend) ->
  if typeof prototype == "function" # first argument is missing => shift arguments
    extend = constructor
    constructor = prototype
    prototype = {}
  # Create function which forwards to given constructor function (if given).
  F = if not constructor? then -> else
    (args) ->
      ret = constructor.apply @, args
      if ret != undefined then ret else @ # if constructor returns not undefined value: use it instead of object
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
