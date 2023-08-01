local M = {}

M.namespace = vim.api.nvim_create_namespace('FloatingHelp')

local defaults = {
  max_width = 80,   -- Whole numbers are columns
  max_height = 0.9, -- Decimals are percentage of editor
  position = 'NW',  -- Cardinal or 'C' for center
  query = '',       -- Stores the search query
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})
end

M.setup()

return M

