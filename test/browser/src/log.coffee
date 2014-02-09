# get export in browser or node.js (after browserify)
_ = if ut1l? then ut1l else require.call null, "../../src/index"

{info, warn, fail} = _.log

describe "Logger", ->

  it "does not throw on level INFO", ->
    (expect (-> info "foo")).not.toThrow()

  it "does not throw on level WARN", ->
    (expect (-> warn "foo")).not.toThrow()

  it "throws on level FAIL", ->
    (expect (-> fail "foo")).toThrow()
