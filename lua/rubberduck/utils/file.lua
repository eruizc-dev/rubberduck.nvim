-- Credits: http://lua-users.org/wiki/FileInputOutput
local io = require("io")

local file = {}

function file.read(filename)
  local f = io.open(filename, "rb")
  local contents = f:read(_VERSION <= "Lua 5.2" and "*a" or "a")
  f:close()
  assert(contents, "Failed to read file")
  return contents
end

return file
