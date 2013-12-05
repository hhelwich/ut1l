# A basic logging module.

# Log info messages for debugging. **TODO**: empty later

module.exports =

  info: (message) ->
    console.log "INFO: #{message}"
    return

  warn: (message) ->
    console.log "WARN: #{message}"
    return

# Throw an application specific error.

  fail: (message) ->
    throw
      #name: "Error"
      message: message
