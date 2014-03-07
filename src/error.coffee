{creator} = require "./object"

toString = ->
  str = if @name? then @name else "Error"
  str += ": #{@message}" if @message?
  str

module.exports = (name, parent) ->
  if parent?
    proto = parent()
  else
    proto = new Error()
    proto.toString = toString # needed for IE6 and IE7
  proto.name = name
  constr = (@message) ->
    e = Error.call @, message # get stack with correct line number
    @stack = e.stack
    return
  creator proto, constr
