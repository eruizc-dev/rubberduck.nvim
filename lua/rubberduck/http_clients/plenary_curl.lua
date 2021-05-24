local json_parser = require("webscope.json_parser")
local curl = require("plenary.curl")
local plenary_curl = {}

local function parse_headers(headers)
  if headers == nil then return {} end

  local parsed_headers = {}
  for _, header in ipairs(headers) do
    local separator_start, separator_end = header:find(":")
    local key = header:sub(1, separator_start - 1)
    local value = header:sub(separator_end + 1, #header)
    if key and value then
      parsed_headers[key:gsub("^%s*(.-)%s*$", "%1")] = value:gsub("^%s*(.-)%s*$", "%1")
    end
  end

  return parsed_headers
end

local function parse_body(body, type)
  if not body then return {} end
  if not type then return body end

  if type:match("application/json") then
    local success, result = pcall(json_parser.deserialize, body)
    if success then return result else
      -- TODO: logerror
    end
  end

  return body
end

local function new_http_request(response)
  if response == nil then return {} end
  local headers = parse_headers(response.headers)
  local body = parse_body(response.body, headers["content-type"])
  return {
    body = body,
    status_code = response.status,
    headers = headers
  }
end

function plenary_curl.get(url, query)
  local result = curl.get({ url = url, query = query })
  if result == nil then
    return new_http_request({ status = 500, body = "Failed to fetch" })
  end
  return new_http_request(result)
end

return plenary_curl
