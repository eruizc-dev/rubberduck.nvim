local mock = require("luassert.mock")
local file = require("rubberduck.utils.file")
local json_parser = require("rubberduck.json_parser")

local github_repositories = require("rubberduck.search_engines.github_repositories")

describe("github_repositories", function()
  local http_client = mock(require("rubberduck.http_client"), true)

  before_each(function()
    mock.clear(http_client)
  end)

  describe("search", function()

    it("returns empty table if api returns nil", function()
      http_client.get.returns(nil)
      local result = github_repositories.search("telescope")
      assert.equal(vim.inspect({}), vim.inspect(result))
    end)

    it("returns empty table if api returns empty table", function()
      http_client.get.returns({})
      local result = github_repositories.search("choo choo")
      assert.equal(vim.inspect({}), vim.inspect(result))
    end)

    it("calls api with correct args", function()
      local question = "how to exit vim"
      github_repositories.search(question)
      assert.stub(http_client.get).was_called_with(
        "https://api.github.com/search/repositories",
        { q = question }
      )
    end)

    it("parses output correctly", function()
      local http_client_response = {
        items = {{
          id = 51980455,
          full_name = "alacritty/alacritty",
          html_url = "https://github.com/alacritty/alacritty",
          description = "A cross-platform, OpenGL terminal emulator."
        }, {
          id = 111277299,
          full_name = "eendroroy/alacritty-theme",
          html_url = "https://github.com/eendroroy/alacritty-theme",
          description = "Collection of Alacritty color schemes"
        }}
      }
      local expected_searcher_output = {{
        link = "https://github.com/alacritty/alacritty",
        title = "alacritty/alacritty"
      }, {
        link = "https://github.com/eendroroy/alacritty-theme",
        title = "eendroroy/alacritty-theme"
      }}
      http_client.get.returns({ body = http_client_response })
      local result = github_repositories.search("exit vim")
      assert.equal(vim.inspect(expected_searcher_output), vim.inspect(result))
    end)

    it("parses actual api response", function()
      local api_response = file.read("./spec/rubberduck/search_engines/github_repositories/alacritty_search.json")
      local parsed_response = json_parser.deserialize(api_response)
      http_client.get.returns({ body = parsed_response })
      local result = github_repositories.search("alacritty")
      for _, item in ipairs(result) do
        assert.are_not_equal(item.title, nil)
        assert.are_not_equal(item.link, nil)
      end
    end)

  end)

  mock.revert(http_client)
end)

