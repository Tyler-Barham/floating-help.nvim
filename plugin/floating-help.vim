command! -nargs=* -complete=custom,s:complete FloatingHelp lua require'floating-help'.open(<f-args>)
command! -nargs=* -complete=custom,s:complete FloatingHelpToggle lua require'floating-help'.toggle(<f-args>)
command! FloatingHelpClose lua require'floating-help'.close()

