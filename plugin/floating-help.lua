local ucmd = vim.api.nvim_create_user_command
local fh = require('floating-help')

ucmd('FloatingHelp', function(opts) fh.open(unpack(opts.fargs)) end, {
  nargs = '*',
  complete = function(_, lines)
    --TODO
  end,
})
ucmd('FloatingHelpToggle', function(opts) fh.toggle(unpack(opts.fargs)) end, {
  nargs = '*',
  complete = function(_, lines)
    --TODO
  end,
})
ucmd('FloatingHelpClose', function() fh.close() end, { nargs = 0 })

