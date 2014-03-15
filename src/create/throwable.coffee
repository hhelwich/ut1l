O = require "./object"

# Top level prototype for all throwables
throwableProto =

  name: "Error"

  toString: -> # needed for IE6 and IE7
    if @message? then "#{@name}: #{@message}" else @name


# Constructor for a top level throwable
createTopThrowable = O throwableProto


# Constructor function for a new throwable
throwableConstr = (@message) ->
  e = Error.call @, message # get stack with correct line number
  if e.stack?
    @stack = e.stack
  return


# Constructor for a new throwable
createCreateThrowable = (name, parent = createTopThrowable) ->
  proto = parent()
  proto.name = name if name?
  O proto, throwableConstr


createCreateThrowable.c4tch = ->
  throwables = []
  for arg, idx in arguments
    if arg.prototype instanceof createTopThrowable
      throwables.push arg
    else
      break
  if throwables.length == 0
    throwables.push createTopThrowable
  action = arguments[idx]
  onError = arguments[idx + 1]
  ->
    try
      action.apply @, arguments
    catch e
      for t in throwables
        if e instanceof t
          return (if onError?
            onError.call @, e)
      throw e


module.exports = createCreateThrowable