local config = require('floating-help.config')
local View = require('floating-help.view')

local FloatingHelp = {}
local view

function FloatingHelp.is_open()
  return view and view:is_valid() or false
end

function FloatingHelp.setup(options)
  config.setup(options)
end

function FloatingHelp.close()
  if FloatingHelp.is_open() then
    view:close()
  end
end

local opt_table = {
  ['p'] = 'position',
  ['w'] = 'width',
  ['h'] = 'height',
  ['t'] = 'type',
}

local function get_opts(...)
  local args = { ... }
  if vim.islist(args) and #args == 1 and type(args[1]) == "table" then
    args = args[1]
  end
  local opts = {}
  for key, value in pairs(args) do

    if type(key) == "number" then
      local k, v = value:match("^(.*)=(.*)$")
      if k then
        -- Expand char opt to str opt
        if string.len(k) == 1 then
          k = opt_table[k]
        end
        -- Convert str to num
        if tonumber(v) then
          opts[k] = tonumber(v)
        else
          opts[k] = v
        end
      else
        -- didn't contain `=`
        opts['query'] = value
      end
    else
      opts[key] = value
    end
  end

  opts = opts or {}
  return opts
end

function FloatingHelp.open(...)
  local opts = get_opts(...)

  if FloatingHelp.is_open() then
    view:update(opts)
  else
    view = View.create(opts)
  end
end

local buffer_position = {}
function FloatingHelp.toggle(...)
  if FloatingHelp.is_open() then
    buffer_position = vim.api.nvim_win_get_cursor(0)
    FloatingHelp.close()
  else
    FloatingHelp.open(...)
    if next(buffer_position) ~= nil then
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, buffer_position)
      end)
    end
  end
end

return FloatingHelp

