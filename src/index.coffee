module.exports = index =
  create:
    object: require "./create/object"
    throwable: require "./create/throwable"

# create global index if in browser
if window?
  window.ut1l = index
