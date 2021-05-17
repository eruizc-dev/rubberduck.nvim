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

local function deserialize_json(json)
  local luafied_json = json
    :gsub("%[", "%{")
    :gsub("%]", "%}")
    :gsub("('[^']-'[%s^:]*):", "[%1]=")
    :gsub('("[^"]-"[%s^:]*):', "[%1]=")
  local func = assert(load("return " .. luafied_json))
  return func()
end

local function parse_body(body, content_type)
  if body == nil then return nil end
  if content_type and content_type:find("application/json") then
    local success, result =  pcall(deserialize_json, body)
    if not success then return body end
    return result
  end
  return body
end

local function new_http_request(response)
  local parsed_headers = response and parse_headers(response.headers)
  local parsed_body = response and parse_body(response.body, parsed_headers["content-type"])
  return {
    body = parsed_body,
    status_code = response and response.status,
    headers = parsed_headers
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
