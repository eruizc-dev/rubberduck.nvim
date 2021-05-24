local random = require("rubberduck.utils.random")

describe("random", function()

  describe("string", function()

    it("returns different strings", function()
      local unique_results = {}
      for _=1,128 do
        unique_results[random.string()] = true
      end

      local unique_results_count = 0
      for _ in pairs(unique_results) do
        unique_results_count = unique_results_count + 1
      end

      assert.equal(128, unique_results_count)
    end)

    it("defaults to length 16", function()
      for _=1,128 do
        local str = random.string()
        assert.equal(16, #str)
      end
    end)

    it("respects length argument", function()
      for l=1,128 do
        local str = random.string(l)
        assert.equal(l, #str)
      end
    end)

    it("respects allowed_chars argument", function()
      local str = random.string(10, 'a')
      assert.equal("aaaaaaaaaa", str)
    end)

  end)

  describe("table", function()
    it("produces a table by default", function()
      local result = random.table()
      assert("table", type(result))
    end)

    it("produces different tables", function()
      local results = {}
      for i=1,128 do
        results[i] = random.table()
      end

      for i = 1, #results do
        for j = i + 1, #results do
          assert.are_not_equal(results[i], results[j], "Found to equal tables")
        end
      end
    end)
  end)
end)

