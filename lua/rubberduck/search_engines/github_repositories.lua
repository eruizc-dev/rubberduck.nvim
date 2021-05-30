local http_client = require("rubberduck.http_client")

local github_repositories = {}

local configuration = {
	base_url = "https://api.github.com/search/repositories",
	default_params = { }
}

local function parse_result(result)
  if type(result) ~= "table" then return {} end
  if type(result.body) ~= "table" then return {} end
  if type(result.body.items) ~= "table" then return {} end

  local parsed_results = {}
  for i, item in ipairs(result.body.items) do
    parsed_results[i] = {
      title = item.full_name,
      link = item.html_url
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

function github_repositories.search(q)
  local params = build_search_params(q)
  local result = http_client.get(configuration.base_url, params)
  return parse_result(result)
end

return github_repositories

