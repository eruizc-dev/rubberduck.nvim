local http_client = require("webscope.http_client")

local stackexchange = {}

local base_url = "https://api.stackexchange.com/2.2"

function stackexchange.search_advanced(site, q, accepted, order)
  assert(site, "site is required")
  local url = base_url.."/search/advanced"
  local params = { site, q, accepted, order }
  local result = http_client.get(url, params)
  if result == nil or result.status_code ~= 200 then
    -- TODO: log error
    return {}
  end
  return result.body or {}
end

return stackexchange
