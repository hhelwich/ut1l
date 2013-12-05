chai = require "chai"
expect = chai.expect

{info, warn, fail} = require "../src/log"

describe "Logger", ->

  it "does not throw on level INFO", ->
    (expect (-> info "foo")).not.to.throw /./

  it "does not throw on level WARN", ->
    (expect (-> warn "foo")).not.to.throw /./

  it "throws on level FAIL", ->
    (expect (-> fail "foo")).to.throw /foo/
