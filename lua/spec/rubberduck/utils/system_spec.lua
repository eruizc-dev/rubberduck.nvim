local mock = require("luassert.mock")
local random = require("rubberduck.utils.random")

local system = require("rubberduck.utils.system")

describe("system", function()
  local Job = mock(require("plenary.job"), true)

  describe("get_name", function()
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
end)
