local mock = require("luassert.mock")
local random = require("webscope.utils.random")

local file = require("webscope.utils.file")

local function assert_reads_correctly_when_content_is(contents)
  io.open.returns({ read = function() return contents end, close = function() end })
  local result = file.read("file.txt")
  assert.equal(contents, result)
end

describe("file", function()

  local io = mock(require("io"), true)

  describe("read", function()

    it("returns file contents", function()
      for length=0,256 do
        local contents = random.string(length)
        io.open.returns({ read = function() return contents end, close = function() end })
        local result = file.read("file.txt")
        assert.equal(contents, result)
      end
    end)

    it("excepts on unexisting file", function()
      io.open.returns(nil)
      assert.has_error(function() file.read("file.txt") end)
    end)

    it("excepts on unreadable file", function()
      io.open.returns({ read = function() return nil end, close = function() end })
      assert.has_error(function() file.read("file.txt") end)
    end)

    it("reads correctly when content is empty", function()
      assert_reads_correctly_when_content_is("")
    end)

    it("reads correctly when content is 'nil'", function()
      assert_reads_correctly_when_content_is("nil")
    end)

    it("reads correctly when content is 'null'", function()
      assert_reads_correctly_when_content_is("null")
    end)


    it("reads correctly when content is '0'", function()
      assert_reads_correctly_when_content_is("0")
    end)

  end)
end)

