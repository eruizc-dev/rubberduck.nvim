local http_client = require("webscope.http_client")

local stack_overflow = {}

local configuration = {
	base_url = "https://api.stackexchange.com/2.2/search/advanced",
	default_params = {
		order = "desc",
		site = "stackoverflow",
		sort = "relevance",
	}
}

local function parse_result(result)
  if type(result) ~= "table" then return {} end
  if type(result.body) ~= "table" then return {} end
  if type(result.body.items) ~= "table" then return {} end

  local parsed_results = {}
  for i, item in ipairs(result.body.items) do
    parsed_results[i] = {
      title = item.title,
      link = item.link
    }
  end

  return parsed_results
end

local function build_search_params(q)
  return {
    order = configuration.default_params.order,
    site = configuration.default_params.site,
    sort = configuration.default_params.sort,
    q = q
  }
end

function stack_overflow.search(q)
  local params = build_search_params(q)
  local result = http_client.get(configuration.base_url, params)
  return parse_result(result)
end

return stack_overflow

