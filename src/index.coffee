module.exports = index =
  log: require "./log"
  obj: require "./obj"

# create global index if in browser
if window?
  window.ut1l = index
