toString = ->
  (if @name? then @name else "Error") + (if @message? then ": #{@message}" else "")

module.exports = (name) ->
  F = (message) ->
    # set message
    @message = message
    # get stack with correct line number
    E = Error.call @, message
    @stack = E.stack
    return
  proto = new Error()
  proto.name = name
  proto.toString = toString # needed for IE6 and IE7
  F.prototype = proto
  F