local config = require('floating-help.config')

local View = {}
View.__index = View

local view = nil

function View:new()
  if view then
    return view
  end

  local this = {
    win_border  = nil,
    buf_border  = nil,
    win_text    = nil,
    buf_text    = nil,
    query       = '',
  }
  setmetatable(this, self)
  return this
end

-- position, editor width/height, window width/height
local function get_anchor(pos,ew,eh,ww,wh)
  -- Center
  local anchor = {
    col = math.floor((ew - ww) / 2),
    row = math.floor((eh - wh) / 2) - 1 -- `-1` offset to always have status/command lines visible
  }

  pos = string.upper(pos)

  if string.match(pos, 'N') ~= nil then
    anchor.row = 0
  end
  if string.match(pos, 'W') ~= nil then
    anchor.col = 0
  end
  if string.match(pos, 'S') ~= nil then
    anchor.row = eh - wh - 2
  end
  if string.match(pos, 'E') ~= nil then
    anchor.col = ew - ww
  end

  return anchor
end

local function get_window_config(opts)
  opts = opts or {}

  config.options.width = opts.width or config.options.width
  config.options.height = opts.height or config.options.height
  config.options.position = opts.position or config.options.position
  config.options.borderchars = opts.borderchars or config.options.borderchars

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local win_width = config.options.width
  local win_height = config.options.height

  -- Redo for percentages
  if win_width < 1 then
    win_width = math.floor(editor_width * win_width)
  end
  if win_height < 1 then
    win_height = math.floor(editor_height * win_height)
  end

  -- clip size
  win_width = math.min(win_width, editor_width)
  win_height = math.min(win_height, editor_height-2) -- `-2` for status and command lines

  local anchor = get_anchor(
    config.options.position,
    editor_width,
    editor_height,
    win_width,
    win_height
  )

  -- Define the window configuration
  local win_config = {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = anchor.col,
    row = anchor.row,
    style = "minimal",
    border = config.options.border or "rounded",
  }

  return win_config
end

function View:setup(opts)
  -- Create buffer
  self.buf_text = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(self.buf_text, "bufhidden", "wipe")

  -- Create floating window
  local win_config = get_window_config(opts)
  win = vim.api.nvim_open_win(self.buf_text, true, win_config)
  vim.opt.winhl = "Normal:Floating"

  -- Focus contents buffer (this must be done after window creation)
  vim.api.nvim_set_current_buf(self.buf_text)

  -- Generate contents

  local ok = true
  local res = ''

  -- First use and no type, default to help
  if not self.query_type and not opts.type then
    opts.type = 'help'
    -- First use and no page, default to help.txt
    if not opts.query then
      opts.query = 'help.txt'
    end
  end

  -- If we have a new query but no type, defualt to help
  -- If we have neither, will be toggling so keep type as last set
  if opts.query and not opts.type then
    opts.type = 'help'
  -- There was type=... but no page to query
  elseif opts.type and not opts.query then
    ok = false
    res = "No query given for "..opts.type.."!"
  end

  local query = opts.query or self.query
  local query_type = opts.type or self.query_type

  -- keep cursor at the center
  vim.schedule(function()
    vim.opt_local.scrolloff = 999
  end)

  -- if not ok, opts were incomplete
  local text_width = win_config.width + 3
  if ok then
    if query_type == 'help' then
      vim.opt_local.filetype = 'help'
      vim.opt_local.buftype = 'help'
      ok, res = pcall(vim.fn.execute, 'help ' .. query)

    elseif query_type == 'cppman' or query_type == 'man' then
      vim.opt_local.filetype = 'man'
      local cmd
      if query_type == 'cppman' then
        cmd = "cppman --force-columns " .. text_width .. " " .. query
      else
        cmd = "MANWIDTH=" .. text_width .. " man " .. query .. " | col -bx"
      end
      local file
      ok, file = pcall(io.popen, cmd)

      if file then
        -- Populate res
        res = file:read('*a')
        file:close()

        -- If no cppman/man page for query
        if (res == nil) or (res == '') or string.match(res, 'No manual entry') then
          ok = false
          res = "No " .. query_type .. " entry for " .. query

        -- Else format cppman/man results
        else
          local lines = {}
          for line in string.gmatch(res, '(.-)\n') do
            table.insert(lines, line)
          end
          vim.api.nvim_buf_set_lines(self.buf_text, 0, -1, true, lines)
        end

      -- Else io.popen failed
      else
        ok = false
        res = "Failed to get " .. query_type .. " results"
      end

    -- Else query_type
    else
      ok = false
      res = "Unsupported query type: " .. query_type
    end
  end

  -- Save the valid query
  if ok then
    self.query = query
    self.query_type = query_type
  -- Handle errors (i.e. no help page)
    if config.options.onload ~= nil then
      config.options.onload(self.query_type)
    end
  elseif not ok then
    view:close()
    vim.api.nvim_echo({{res, 'Error'}}, true, {})
  end
end

function View:is_valid()
  return self.buf_text and vim.api.nvim_buf_is_valid(self.buf_text) and vim.api.nvim_buf_is_loaded(self.buf_text)
end

function View:close()
  if self.win_text and vim.api.nvim_win_is_valid(self.win_text) then
    vim.api.nvim_win_close(self.win_text, {})
    self.win_text = nil
  end
  if self.win_border and vim.api.nvim_win_is_valid(self.win_border) then
    vim.api.nvim_win_close(self.win_border, {})
    self.win_border = nil
  end
  if self.buf_text and vim.api.nvim_buf_is_valid(self.buf_text) then
    vim.api.nvim_buf_delete(self.buf_text, {})
    self.buf_text = nil
  end
  if self.buf_border and vim.api.nvim_buf_is_valid(self.buf_border) then
    vim.api.nvim_buf_delete(self.buf_border, {})
    self.buf_border = nil
  end

  vim.fn.execute('doautocmd WinEnter')
end

function View:update(opts)
  view:close()    -- Close and cleanup (losing self ref)
  view:setup(opts)   -- Run a clean setup
end

function View.create(opts)
  opts = opts or {}

  view = View:new()
  view:update(opts)

  return view
end

return View

