local mock = require("luassert.mock")
local file = require("webscope.utils.file")

local stackexchange = require("webscope.apis.stackexchange")

describe("stackexchange", function()
  local http_client = mock(require("webscope.http_client"), true)

  before_each(function()
    mock.clear(http_client)
  end)

  describe("search_advanced", function()

    it("raises error if site is not specified", function()
      assert.has_error(
        function() stackexchange.search_advanced() end,
        "site is required"
      )
    end)

    it("doesn't make api call if site is not specified", function()
      pcall(stackexchange.search_advanced)
      assert.stub(http_client.get).was_not_called()
    end)

    it("returns all questions if no parameters are passed", function()
      local expected_body = file.read("./spec/webscope/apis/stackexchange/search_advanced_stackoverflow_all.json")
      http_client.get.returns({ status_code = 200, body = expected_body })
      local result = stackexchange.search_advanced("stackoverflow")
      assert.equal(expected_body, result)
    end)

  end)

  mock.revert(http_client)
end)

