local ucmd = vim.api.nvim_create_user_command
local fh = require('floating-help')

--- Complete the ArgLead with a custom completion list.
--- The list does not have to searched through vim will do that for you.
--- @param ArgLead string The leading portion of the argument currently being completed on.
--- @param CmdLine string The entire command line.
--- @param CursorPos number The cursor position in it (byte index).
--- @return table
local function completion(ArgLead, CmdLine, CursorPos)
  -- TODO: Make completions based on the ArgLead and return predictions as a list.
  -- Currently is a no op.
  return {ArgLead}
end

ucmd('FloatingHelp', function(opts)
  fh.open(unpack(opts.fargs))
end, {
  nargs = '*',

  --- For reference the values of the `complete` attribute can be found in the help:
  --- `:h :command-completion`
  complete = 'help',

  --- For reference when the `complete` attribute is a function, can be found in the help:
  --- `:h :command-completion-customlist`
  -- complete = completion
})
ucmd('FloatingHelpToggle', function(opts) fh.toggle(unpack(opts.fargs)) end, {
  nargs = '*',

  --- For reference the values of the `complete` attribute can be found in the help:
  --- `:h :command-completion`
  complete = 'help',

  --- For reference when the `complete` attribute is a function, can be found in the help:
  --- `:h :command-completion-customlist`
  -- complete = completion
})
ucmd('FloatingHelpClose', function() fh.close() end, { nargs = 0 })
