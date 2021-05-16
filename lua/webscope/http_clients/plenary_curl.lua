local curl = require("plenary.curl")
local plenary_curl = {}

local function parse_headers(headers)
  local parsed_headers = {}
  if headers == nil then return parsed_headers end

  for _, header in ipairs(headers) do
    local separator_start, separator_end = header:find(": ")
    local key = header:sub(1, separator_start - 1)
    local value = header:sub(separator_end + 1, #header)
    parsed_headers[key] = value
  end

  return parsed_headers
end

local function new_http_request(response)
  return {
    body = response.body,
    status_code = response.status,
    headers = parse_headers(response.headers)
  }
end

function plenary_curl.get(url, params)
  local result = curl.get({ url = url, params = params })
  if result == nil then
    return new_http_request({ status = 500, body = "Failed to fetch" })
  end
  return new_http_request(result)
end

return plenary_curl
