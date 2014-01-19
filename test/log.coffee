
{info, warn, fail} = require "../src/log"

describe "Logger", ->

  it "does not throw on level INFO", ->
    (expect (-> info "foo")).not.toThrow()

  it "does not throw on level WARN", ->
    (expect (-> warn "foo")).not.toThrow()

  it "throws on level FAIL", ->
    (expect (-> fail "foo")).toThrow()
