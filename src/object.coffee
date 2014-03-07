module.exports =

  # Return a function which creates a new object with the given prototype and initializes this object with the given
  # constructor function (if given).
  # Also copy optional `extend` object content to returned function.
  creator: (prototype, constructor, extend) ->
    if typeof prototype == "function" # first argument is missing => shift arguments
      f = prototype
      extend = constructor
    else
      # Create function which forwards to given constructor function (if given).
      F = if not constructor? then -> else
        (args) ->
          ret = constructor.apply @, args
          if ret != undefined then ret else @ # if constructor returns not undefined value: use it instead of object
      # Set functions prototype field.
      F.prototype = prototype
      # Create function which creates a new object with the given prototype and initializes with the given constructor.
      f = -> new F arguments
    # Add static fields to function.
    for key, value of extend
      f[key] = value
    f.prototype = prototype
    f
