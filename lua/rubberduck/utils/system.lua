local Job = require("plenary.job")

local system = {}

function system.get_system_name()
  local sys = Job:new({ command = "uname" }):sync()
  if type(sys) == "table" and sys[1] then
    return sys[1]
  end
  return "unknown"
end

function system.get_open_command()
  local sys_name = system.get_system_name()

  if sys_name == "Linux" then return "xdg-open" end
  if sys_name == "Darwin" then return "open" end
  error("Unsupported system '" .. sys_name .. "'")
end

function system.open(link)
  if type(link) ~= "string" then error("Expected link to be type 'string' but got '" .. type(link) .. "'") end
  local open_command = system.get_open_command()
  local vim_command = string.format("silent !%s '%s'", open_command, link)
  vim.api.nvim_command(vim_command)
end

return system
