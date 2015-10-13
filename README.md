### dumbest tslime.vim ###

My link in a chain of forks. 
I took code from [sjl](https://github.com/sjl/tslime.vim).
I zink you better to use [this](https://github.com/jgdavey/tslime.vim.git).

Code may be  ugly but simple. The following is mostly a reminder for myself.

If there is just one pane then create and connect to it otherwise your vim
would be connected to the last used pane.  You might send a line, paragraph,
selection or whole file to a another pane.

Bindings: `<leader>t` + mnemonic letters. 
 + `let g:tslime_create_pane = '<leader>tc'`  -- create a pane.
 + `let g:tslime_send_line = '<leader>tl'`  -- send a line.
 + `let g:tslime_send_paragraph = '<leader>tp'` -- send paragraph.
 + `let g:tslime_send_all = '<leader>ta'`   -- send whole file.
 + `let g:tslime_send_selected = '<leader>ts'` -- send selected lines.
also,  there are `g:tslime_ensure_trailing_newlines` option, which is useless right now. 
You might remap any bind. 
NOTE: selected lines == lines selected in visual mode, not just selected area.

`¯\_(ツ)_/¯`

