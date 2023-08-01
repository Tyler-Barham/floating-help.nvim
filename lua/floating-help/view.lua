local config = require('floating-help.config')

local View = {}
View.__index = View

function View:new(opts)
  opts = opts or {}

  local this = {
    win_border = nil,
    buf_border = nil,
    win_text   = nil,
    buf_text   = nil,
  }
  setmetatable(this, self)
  return this
end

-- position, editor width/height, window width/height
local function get_anchor(pos,ew,eh,ww,wh)
  -- Center
  local anchor = {
    col = math.floor((ew - ww) / 2),
    row = math.floor((eh - wh) / 2)
  }

  if string.match(pos,'N') ~= nil then
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

function View:setup(opts)
  opts = opts or {}

  config.options.max_width = opts.max_width or config.options.max_width
  config.options.max_height = opts.max_height or config.options.max_height
  config.options.position = opts.position or config.options.position

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local win_width = config.options.max_width
  local win_height = config.options.max_height
  if win_width < 1 then
    win_width = math.floor(editor_width * win_width)
  end
  if win_height < 1 then
    win_height = math.floor(editor_height * win_height)
  end

  local anchor = get_anchor(
    config.options.position,
    editor_width,
    editor_height,
    win_width,
    win_height
  )

  -- Define the window configuration
  local win_config_border = {
      relative = 'editor',
      width    = win_width,
      height   = win_height,
      col      = anchor.col,
      row      = anchor.row,
      style    = 'minimal',
  }

  local border_top = "╭" .. string.rep("─", win_width - 2) .. "╮"
  local border_mid = "│" .. string.rep(" ", win_width - 2) .. "│"
  local border_bot = "╰" .. string.rep("─", win_width - 2) .. "╯"
  local border = { border_top }
  for _ = 1, win_height-2 do
      table.insert(border, border_mid)
  end
  table.insert(border, border_bot)

  -- Create a floating window for the border
  self.buf_border = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(self.buf_border, 0, -1, true, border)
  self.win_border = vim.api.nvim_open_win(self.buf_border, true, win_config_border)
  vim.opt.winhl = 'Normal:Floating'

  local win_conf_text = {
      relative = win_config_border.relative,
      width    = win_config_border.width - 2,
      height   = win_config_border.height - 2,
      col      = win_config_border.col + 1,
      row      = win_config_border.row + 1
  }

  -- Create a floating window for the content
  self.buf_text = vim.api.nvim_create_buf(false, true)
  self.win_text = vim.api.nvim_open_win(self.buf_text, true, win_conf_text)

  -- TODO: Allow the win/buf to persist so we can edit files with this window still open
  -- vim.api.nvim_create_autocmd('BufLeave', {
  --     command = string.format('bw %s | bw %s', self.buf_border, self.buf_text),
  --     once = true
  -- })

  -- Set props
  vim.api.nvim_set_current_buf(self.buf_text)
  vim.opt_local.filetype = 'help'
  vim.opt_local.buftype = 'help'

  local query = opts.query or ''
  vim.fn.execute('help ' .. query)
end

function View:is_valid()
  return vim.api.nvim_buf_is_valid(self.buf_text) and vim.api.nvim_buf_is_loaded(self.buf_text)
end

function View:close()
  if vim.api.nvim_win_is_valid(self.win_text) then
    vim.api.nvim_win_close(self.win_text, {})
  end
  if vim.api.nvim_win_is_valid(self.win_border) then
    vim.api.nvim_win_close(self.win_border, {})
  end
  if vim.api.nvim_buf_is_valid(self.buf_text) then
    vim.api.nvim_buf_delete(self.buf_text, {})
  end
  if vim.api.nvim_buf_is_valid(self.buf_border) then
    vim.api.nvim_buf_delete(self.buf_border, {})
  end
end

function View:update(...)
  -- TODO
end

function View.create(opts)
  opts = opts or {}

  local buffer = View:new(opts)
  buffer:setup(opts)

  return buffer
end

return View

