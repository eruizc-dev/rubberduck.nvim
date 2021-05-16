local curl = require("plenary.curl")
local plenary_curl = {}

local function new_http_request(status_code, body)
  return {
    body = body,
    status_code = status_code,
  }
end

function plenary_curl.get(url, params)
  local result = curl.get({ url, params })
  if result == nil then
    return new_http_request(500, "Failed to fetch")
  end
  return new_http_request(result.status, result.body)
end

return plenary_curl
