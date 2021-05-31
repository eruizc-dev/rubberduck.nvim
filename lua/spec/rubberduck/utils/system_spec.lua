local mock = require("luassert.mock")
local stub = require("luassert.stub")
local random = require("rubberduck.utils.random")

describe("system", function()
  local system = require("rubberduck.utils.system")
  describe("get_name", function()
    local Job = mock(require("plenary.job"), true)

    it("returns Linux if system is Linux", function()
      Job.new.returns({ sync = function() return { "Linux" } end })
      local result = system.get_system_name()
      assert.equal("Linux", result)
    end)

    it("returns Darwin if system is Darwin", function()
      Job.new.returns({ sync = function() return { "Darwin" } end })
      local result = system.get_system_name()
      assert.equal("Darwin", result)
    end)

    it("returns unknown if system is something else", function()
      for _=1,128 do
        local sys_name = random.string(8)
        Job.new.returns({ sync = function() return { sys_name } end })
        local result = system.get_system_name()
        assert.equal(sys_name, result)
      end
    end)
  end)

  describe("get_open_command", function()
    after_each(function()
      if system.get_system_name.revert then
        system.get_system_name:revert()
      end
    end)

    it("excepts when system is unknown", function()
      stub(system, "get_system_name", function() return "unknown" end)
      assert.has_error(function() system.get_open_command() end, "Unsupported system 'unknown'")
    end)

    it("excepts when system is not supported", function()
      local sys_name = random.string(8)
      stub(system, "get_system_name", function() return sys_name end)
      assert.has_error(function() system.get_open_command() end, "Unsupported system '" .. sys_name .. "'")
    end)

    it("returns xdg-open for system Linux", function()
      stub(system, "get_system_name", function() return "Linux" end)
      local cmd = system.get_open_command()
      assert.equal("xdg-open", cmd)
    end)

    it("returns open for system Darwin", function()
      stub(system, "get_system_name", function() return "Darwin" end)
      local cmd = system.get_open_command()
      assert.equal("open", cmd)
    end)
  end)

  describe("open", function()
    it("excepts if argument is not a string", function()
      local invalid_args = { 13, function() end, { results = 10 }, { 1, 2, 3 } }
      for _, arg in ipairs(invalid_args) do
        assert.has_error(function() system.open(arg) end, "Expected link to be type 'string' but got '" .. type(arg) .. "'")
      end
    end)

    it("executes correct command", function()
      stub(vim.api, "nvim_command")
      stub(system, "get_open_command", function() return "open" end)
      for _ = 1, 128 do
        local link = random.string()
        system.open(link)
        assert.stub(vim.api.nvim_command).was_called_with("silent !open '"..link.."'")
      end
    end)
  end)
end)
