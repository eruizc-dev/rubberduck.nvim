local mock = require("luassert.mock")
local random = require("rubberduck.utils.random")

local client = require("rubberduck.http_clients.plenary_curl")

describe("plenary_curl", function()
  local curl = mock(require("plenary.curl"), true)

  before_each(function()
    mock.clear(curl)
  end)

  describe("get", function()

    it("invokes curl with correct url and query", function()
      local url = "https://api.somewebsite.com"
      local query = { q = "how to exit vim", sort = "asc"}
      client.get(url, query)
      assert.stub(curl.get).was_called_with({ url = url, query = query })
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

    it("doesn't change return body if content-type is not specified", function()
      for _=1, 256 do
        local body = random.string(64)
        curl.get.returns({ status = 200, body = body })
        local result = client.get("http://ajfkdslajfs.com")
        assert.equal(body, result.body)
      end
    end)

    it("returns empty table if headers nil", function()
      curl.get.returns({ headers = nil })
      local result = client.get("https://api.somewebsite.com")
      assert.equal(vim.inspect({}), vim.inspect(result.headers))
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

    it("returns body parsed as json if conten-type is application/json", function()
      local headers = {
        "content-type: application/json",
        "content-type: application/json; charset=utf-8",
        "content-type:application/json",
        "content-type:application/json;charset=utf-8",
      }
      local raw_json =  [[{
        "users": ["jhon", "johana"],
        "count": 2,
        "filters": { "startingLetter": "j", "age": 25 }
      }]]
      local parsed_json = {
        users = { "jhon", "johana" },
        count = 2,
        filters = { startingLetter = "j", age = 25 }
      }

      for _, header in ipairs(headers) do
        curl.get.returns({ body = raw_json, headers = { header } })
        local result = client.get("https://api.somewebsite.com")
        assert.equal(vim.inspect(parsed_json), vim.inspect(result.body))
      end

    end)

    it("doesn't break with an empty header", function()
      local headers = { "content-type: application/json", "" }
      curl.get.returns({ body = "{ 'count': 10 }", headers = headers })
      assert(client.get("https://api.somewebsite.com"))
    end)

  end)

  mock.revert(curl)
end)

