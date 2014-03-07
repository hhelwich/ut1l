module.exports = index =
  object: require "./object"
  error: require "./error"

# create global index if in browser
if window?
  window.ut1l = index
