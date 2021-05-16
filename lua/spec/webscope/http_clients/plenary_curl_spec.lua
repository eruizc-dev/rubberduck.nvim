local mock = require("luassert.mock")

local client = require("webscope.http_clients.plenary_curl")

describe("plenary_curl", function()
  local curl = mock(require("plenary.curl"), true)

  before_each(function()
    mock.clear(curl)
  end)

  describe("get", function()

    it("invokes curl with correct url and params", function()
      local url = "https://api.somewebsite.com"
      local params = { q = "how to exit vim", sort = "asc"}
      client.get(url, params)
      assert.stub(curl.get).was_called_with({ url = url, params = params })
    end)

    it("returns 500 if receives nil", function()
      curl.get.returns(nil)
      local result = client.get("https://api.somewebsite.com")
      assert.equal(500, result.status_code)
    end)

    it("returns errmsg if receives nil", function()
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

    it("returns headers parsed", function()
      local raw_headers = {
        "content-type: application/json; charset=utf-8",
        "content-encoding: gzip"
      }
      local parsed_headers = {
        ["content-type"] = "application/json; charset=utf-8",
        ["content-encoding"] = "gzip"
      }
      curl.get.returns({ headers = raw_headers })
      local result = client.get("https://api.somewebsite.com")
      assert.equal(vim.inspect(parsed_headers), vim.inspect(result.headers))
    end)

    --it("returns body parsed as json if conten-type is json", function()
    --  local raw_json =  [[{
    --    'users': ['jhon', 'johana'],
    --    'count': 2,
    --    'filters': { 'startingLetter': 'j', 'age': 25 }
    --  }]]
    --  local parsed_json = {
    --    users = { "jhon", "johana" },
    --    count = 2,
    --    filters = { startingLetter = "j", age = 25 }
    --  }
    --  local headers = { "content-type: application/json" }

    --  curl.get.returns({ body = raw_json, headers = headers })
    --  local result = client.get("https://api.somewebsite.com")
    --  assert.equal(vim.inspect(parsed_json), vim.inspect(result.body))
    --end)

  end)

  mock.revert(curl)
end)

