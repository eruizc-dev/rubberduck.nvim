local json_lua = require("webscope.json_parsers.json_lua")

describe("json_lua", function()

  describe("deserialize", function()

    it("only accepts strings", function()
      local non_strings = {
        999, 123, 420, 110,
        false, true,
        function() return "I'm a function" end,
        { 3, 2, 1 },
        { "This", "is", "a", "string", "array "},
        { name = "Raul", age = 33, job = { company = "Box", position = "Major" } }
      }
      for _, non_string in ipairs(non_strings) do
        assert.has_error(
          function() json_lua.deserialize(non_string) end,
          "Invalid argument type, expected 'string' got '" .. type(non_string) .. "'"
        )
      end
    end)

    it("returns error on 'nil'", function()
      assert.has_error(
        function() json_lua.deserialize(nil) end,
        "Invalid argument type, expected 'string' got 'nil'"
      )
    end)

    it("deserializes basic json", function()
      local json = "[1, 2, 3]"
      local expected = { 1, 2, 3 }
      local result = json_lua.deserialize(json)
      assert.equal(vim.inspect(expected), vim.inspect(result))
    end)

    it("deserializes complex json", function()
      local json = [[{
        "glossary": {
          "title": "example glossary",
          "GlossDiv": {
            "title": "S",
            "GlossList": {
              "GlossEntry": {
                "ID": 8832,
                "SortAs": "SGML",
                "GlossTerm": "Standard Generalized Markup Language",
                "Acronym": "SGML",
                "Abbrev": "ISO 8879:1986",
                "GlossDef": {
                  "para": "A meta-markup language, used to create markup languages such as DocBook.",
                  "GlossSeeAlso": ["GML", "XML"]
                },
                "GlossSee": "markup"
              }
            }
          }
        }
      }]]

      local expected = {
        glossary = {
          GlossDiv = {
            GlossList = {
              GlossEntry = {
                Abbrev = "ISO 8879:1986",
                Acronym = "SGML",
                GlossDef = {
                  GlossSeeAlso = { "GML", "XML" },
                  para = "A meta-markup language, used to create markup languages such as DocBook."
                },
                GlossSee = "markup",
                GlossTerm = "Standard Generalized Markup Language",
                ID = 8832,
                SortAs = "SGML"
              }
            },
            title = "S"
          },
          title = "example glossary"
        }
      }
      local result = json_lua.deserialize(json)
      assert.equal(vim.inspect(expected), vim.inspect(result))
    end)

    it("deserializes json with escaped characters", function()
      local json = '{ "phrase": "This is a \\"word\\"" }'
      local expected = { phrase = 'This is a "word"' }
      local result = json_lua.deserialize(json)
      assert.equal(vim.inspect(expected), vim.inspect(result))
    end)

  end)
end)
