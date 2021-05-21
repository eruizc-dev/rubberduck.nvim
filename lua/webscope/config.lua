local config = {
  default = {
    stackoverflow = {
      base_url = "https://api.stackexchange.com/2.2/search/advanced",
      params = {
        site = "stackoverflow",
        order = "desc",
        sort = "relevance",
      }
    }
  }
}

function config.get_default_config()
  return config.default
end

function config.set_config(cfg)
  if type(cfg) ~= "table" then error("Wrong configuration type, expected: table got: "..type(cfg)) end
  config.active = cfg
end

function config.get_config()
  assert(config.active, "Webscope not configured yet")
  return config.active
end

return config
