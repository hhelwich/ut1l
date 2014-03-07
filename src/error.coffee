creator = require "./object"

errorProto =

  name: "Error"

  toString: -> # needed for IE6 and IE7
    if @message? then "#{@name}: #{@message}" else @name


errorConstr = (@message) ->
  e = Error.call @, message # get stack with correct line number
  @stack = e.stack
  return


errorExtend =

  snatch: (action, onError) ->
    builder = @
    ->
      try
        action.apply @, arguments
      catch e
        if e instanceof builder
          onError.call @, e
        else
          throw e


errorBuilder = creator errorProto, errorConstr, errorExtend


module.exports = (name, parent = errorBuilder) ->
  proto = parent()
  proto.name = name if name?
  creator proto, errorConstr, errorExtend
