local spec_helper = require "spec.spec_helpers"
local http_client = require "kong.tools.http_client"
local cjson = require "cjson"

local STUB_GET_URL = spec_helper.STUB_GET_URL

describe("Hiren Plugin", function()
  setup(function()
    spec_helper.prepare_db()
    spec_helper.insert_fixtures {
      api = {
        {request_host = "test1.com", upstream_url = "http://mockbin.com"}
      },
      plugin = {
        {name = "hiren", config = {}, __api = 1}
      }
    }
    spec_helper.start_kong()
  end)
  teardown(function()
    spec_helper.stop_kong()
  end)

  it("adds the X-User-Name-Initials header to the upstream request", function()
    local response, status = http_client.get(STUB_GET_URL, {firstName = "hiren", lastName = "kotadia"}, {host = "test1.com"})
    local body = cjson.decode(response)
    assert.equal(200, status)
    assert.equal("hk", body.headers["x-user-name-initials"])
  end)

end)
