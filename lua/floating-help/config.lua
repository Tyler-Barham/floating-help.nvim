local M = {}

M.namespace = vim.api.nvim_create_namespace('FloatingHelp')

local defaults = {
  width = 80,   -- Whole numbers are columns/rows
  height = 0.9, -- Decimals are a percentage of the editor
  position = 'E',   -- NW,N,NW,W,C,E,SW,S,SE (C==center)
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})
end

M.setup()

return M

