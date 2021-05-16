local mock = require("luassert.mock")

local client = require("webscope.http_client.plenary_curl")

describe("plenary_curl", function()
  local curl = mock(require("plenary.curl"), true)

  describe("get", function()

    it("invokes curl with correct url and params", function()
      local url = "https://api.somewebsite.com"
      local params = { q = "how to exit vim", sort = "asc"}
      curl.get.returns(nil)
      client.get(url, params)
      assert.stub(curl.get).was_called_with({ url, params })
    end)

    it("returns 500 if receives null", function()
      curl.get.returns(nil)
      local result = client.get("https://api.somewebsite.com")
      assert.equal(500, result.status_code)
    end)

    it("returns errmsg if receives null", function()
      curl.get.returns(nil)
      local result = client.get("https://api.somewebsite.com")
      assert.equal("Failed to fetch", result.body)
    end)

    it("doesn't change return status code", function()
      for http_status_code=100,599 do
        curl.get.returns({ status = http_status_code })
        local result = client.get("http://ajfkdslajfs.com")
        assert.equal(http_status_code, result.status_code)
      end
    end)

    it("doesn't change return body", function()
      local body = "<html></html>"
      curl.get.returns({ status = 200, body = body })
      local result = client.get("http://ajfkdslajfs.com")
      assert.equal(body, result.body)
    end)

  end)

  mock.revert(curl)
end)

