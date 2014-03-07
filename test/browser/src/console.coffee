# add dummy console if none is available

if console?
  console.log "INFO: Console is available"
else
  @console =
    log: ->
