local math = require("math")
local os = require("os")
local random = {}

math.randomseed(os.time())

function random.string(length, allowed_chars)
  length = length or 16
  allowed_chars = allowed_chars or "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  local randomString = ''
  for _ = 1, length do
    local i = math.random(1, #allowed_chars)
    randomString = randomString .. string.sub(allowed_chars, i, i)
  end

  return randomString
end

function random.table(items)
  items = items or 16
  local random_table = {}
  for _ = 1, items do
    local key = random.string()
    local value = random.string()
    random_table[key] = value
  end
  return random_table
end

return random
