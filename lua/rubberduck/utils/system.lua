local Job = require("plenary.job")

local system = {}

function system.get_system_name()
  local sys = Job:new({ command = "uname" }):sync()
  if type(sys) == "table" and sys[1] then
    return sys[1]
  end
  return "unknown"
end

return system
