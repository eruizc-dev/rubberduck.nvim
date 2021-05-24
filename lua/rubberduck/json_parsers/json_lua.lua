local parser = require("json_lua.json")

local json_lua = {}

function json_lua.deserialize(str)
  if type(str) ~= "string" then
    error("Invalid argument type, expected 'string' got '" .. type(str) .. "'")
  end
  return parser.decode(str)
end

return json_lua
