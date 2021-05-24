local random = require("rubberduck.utils.random")

describe("config", function()
  local config = require("rubberduck.config")

  describe("get_default_config", function()
    local default_config = config.get_default_config()
    it("is a table", function()
      assert.equal("table", type(default_config))
    end)

    it("has correct shape", function()
      for _, v in pairs(default_config) do
        assert.equal("string", type(v.base_url))
        assert.equal("table", type(v.params))
      end
    end)
  end)

  describe("set_config", function()
    it("throws error if you don't set table", function()
      local invalid_args = {
        "hi",
        33,
        function() return "i'm a function" end,
        nil
      }
      for _, arg in ipairs(invalid_args) do
      assert.has_error(function() config.set_config(arg) end)
      end
    end)
  end)

  describe("get_config", function()
    it("Gets exactly what has been setted", function()
      local random_config = random.table(16)

      config.set_config(random_config)
      local returned_config = config.get_config()

      assert.equal(vim.inspect(random_config), vim.inspect(returned_config))
    end)
  end)
end)

