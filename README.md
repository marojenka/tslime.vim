### dumbest tslime.vim ###

My link in a chain of forks. 
I took code from [sjl](https://github.com/sjl/tslime.vim).
I zink you better to use [this](https://github.com/jgdavey/tslime.vim.git).

Code may be  ugly but simple. The following is mostly a reminder for myself.

I just wanted a simple way to create new pane and send text into it.  This
version does just that. It create a pane and allow you to send a line, a
paragraph, selected lines or a while file to new pane.  There is no check if we
are inside tmux session, no control over pane's death, no way to connect to
existing pane. 

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

