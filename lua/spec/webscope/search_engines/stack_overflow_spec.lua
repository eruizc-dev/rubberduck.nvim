local mock = require("luassert.mock")
local file = require("webscope.utils.file")
local json_parser = require("webscope.json_parser")

local stack_overflow = require("webscope.search_engines.stack_overflow")

describe("stack_overflow", function()
  local http_client = mock(require("webscope.http_client"), true)

  before_each(function()
    mock.clear(http_client)
  end)

  describe("search", function()

    it("returns empty table if api returns nil", function()
      http_client.get.returns(nil)
      local result = stack_overflow.search("choo choo")
      assert.equal(vim.inspect({}), vim.inspect(result))
    end)

    it("returns empty table if api returns empty table", function()
      http_client.get.returns({})
      local result = stack_overflow.search("choo choo")
      assert.equal(vim.inspect({}), vim.inspect(result))
    end)

    it("calls api with correct args", function()
      local question = "how to exit vim"
      stack_overflow.search(question)
      assert.stub(http_client.get).was_called_with(
        "https://api.stackexchange.com/2.2/search/advanced", {
          order = "desc",
          site = "stackoverflow",
          sort = "relevance",
          q = question
        }
      )
    end)

    it("parses output correctly", function()
      local http_client_response = {
        items = {{
          id = 33,
          link = "https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor",
          title = "How do I exit the Vim editor?"
        }, {
          id = 71,
          owner = {
            id = 12,
            name = "Martin"
          },
          link = "https://stackoverflow.com/questions/1879219/how-to-temporarily-exit-vim-and-go-back",
          title = "How to temporarily exit Vim and go back"
        }}}
      local expected_searcher_output = {{
        link = "https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor",
        title = "How do I exit the Vim editor?"
      }, {
        link = "https://stackoverflow.com/questions/1879219/how-to-temporarily-exit-vim-and-go-back",
        title = "How to temporarily exit Vim and go back"
      }}
      http_client.get.returns({ body = http_client_response })
      local result = stack_overflow.search("exit vim")
      assert.equal(vim.inspect(expected_searcher_output), vim.inspect(result))
    end)

    it("parses actual api response", function()
      local api_response = file.read("./spec/webscope/search_engines/stack_overflow/exit_vim_search.json")
      local parsed_response = json_parser.deserialize(api_response)
      http_client.get.returns({ body = parsed_response })
      local result = stack_overflow.search("exit vim")
      for _, item in ipairs(result) do
        assert.are_not_equal(item.title, nil)
        assert.are_not_equal(item.link, nil)
      end
    end)

  end)

  mock.revert(http_client)
end)

