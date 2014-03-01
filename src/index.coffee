module.exports = index =
  obj: require "./obj"
  error: require "./error"

# create global index if in browser
if window?
  window.ut1l = index
