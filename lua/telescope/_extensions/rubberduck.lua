local pickers = require("telescope.pickers")
local system = require("rubberduck.utils.system")
local async_lib = require("plenary.async_lib")
local async = async_lib.async
local await = async_lib.await
local void = async_lib.void

local function open_url(url)
  local open_cmd = system.get_system_name() == "Darwin" and "open" or "xdg-open"
  local command = string.format("silent !%s '%s'", open_cmd, url)
  vim.api.nvim_command(command)
end

local function stackoverflow()
  local question =  vim.fn.input("Ask StackOverlow > ")
  local input_results = require("rubberduck.search_engines.stack_overflow").search(question)
  local results = {}
  for i, v in ipairs(input_results) do
    table.insert(results, setmetatable({
      v.title,
      link = v.link,
      index = i,
    }, {
      __index = function(t, k)
        return rawget(t, rawget({
          display = 1,
          ordinal = 1,
          value = 1,
        }, k))
      end
    }))
  end

  pickers.new({}, {
    prompt_title = " StackOverlow",
    attach_mappings = function(prompt_bufnr, map)
      local function open()
        local content = require("telescope.actions.state").get_selected_entry()
        open_url(content.link)
        require("telescope.actions").close(prompt_bufnr)
      end

      map("i", "<CR>", open)

      return true
    end,
    finder = setmetatable({
      results = results,
    }, {
      __call = void(async(function(_, _, process_result, process_complete)
        for i, v in ipairs(results) do
          if process_result(v) then break end

          if i % 1000 == 0 then
            await(async_lib.scheduler())
          end
        end
        process_complete()
      end)),
    })
  }):find()
end

return require("telescope").register_extension({
  exports = {
    stackoverflow = stackoverflow
  }
})
