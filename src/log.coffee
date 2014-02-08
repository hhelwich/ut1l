# A basic logging module.

module.exports =

  info: (message) ->
    #console.log "INFO: #{message}"
    return

  warn: (message) ->
    #console.log "WARN: #{message}"
    return

# Throw an application specific error.

  fail: (message) ->
    throw
      #name: "Error"
      message: message
