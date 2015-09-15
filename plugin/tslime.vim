" fork of a fork of a fork of a ... fork of a Tslime.vim
" https://github.com/marojenka

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

if !exists("g:tslime_ensure_trailing_newlines")
  let g:tslime_ensure_trailing_newlines = 0
endif
" if !exists("g:tslime_normal_mapping")
"   let g:tslime_normal_mapping = '<leader>'
" endif
" if !exists("g:tslime_visual_mapping")
"   let g:tslime_visual_mapping = '<c-c><c-c>'
" endif
" if !exists("g:tslime_vars_mapping")
"   let g:tslime_vars_mapping = '<c-c>v'
" endif
if !exists("g:tslime_create_pane")
    let g:tslime_create_pane = '<leader>tc'
endif
if !exists("g:tslime_send_line")
    let g:tslime_send_line = '<leader>tl'
endif
if !exists("g:tslime_send_paragraph")
    let g:tslime_send_paragraph = '<leader>tp'
endif
if !exists("g:rslime_send_all")
    let g:tslime_send_all = '<leader>ta'
endif
if !exists("g:tslime_send_selected")
    let g:tslime_send_selected = '<leader>ts'
endif

"""""""
function SendCmdToR_TmuxSplit(cmd)
    if g:vimrplugin_ca_ck
        let cmd = "\001" . "\013" . a:cmd
    else
        let cmd = a:cmd
    endif

    if !exists("g:rplugin_rconsole_pane")
        " Should never happen
        call RWarningMsg("Missing internal variable: g:rplugin_rconsole_pane")
    endif
    let str = substitute(cmd, "'", "'\\\\''", "g")
    if str =~ '^-'
        let str = ' ' . str
    endif
    let scmd = "tmux set-buffer '" . str . "\<C-M>' && tmux paste-buffer -t " . g:rplugin_rconsole_pane
    let rlog = system(scmd)
    if v:shell_error
        let rlog = substitute(rlog, "\n", " ", "g")
        let rlog = substitute(rlog, "\r", " ", "g")
        call RWarningMsg(rlog)
        call ClearRInfo()
        return 0
    endif
    return 1
endfunction

" Get the name of active pane. 
" code from vim-r-pugin 
function! TmuxActivePane()
    let line = system("tmux list-panes | grep \'(active)$'")
    let paneid = matchstr(line, '\v\%\d+ \(active\)')
    if !empty(paneid)
        return matchstr(paneid, '\v^\%\d+')
    else
        return matchstr(line, '\v^\d+')
    endif
endfunction

function s:Tmux_Create_Pane() 
    " I don't want to bother with checking if we are 
    " in tmux
    let log = system("tmux split-window ")
    let b:created_pane = TmuxActivePane()
endfunction



"""""""
" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
    if !exists("b:created_pane")
        echo "There is no pane to work with"
        return "42"
    end
    "     if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname") || !exists("b:tmux_panenumber")
    "         if exists("g:tmux_sessionname") && exists("g:tmux_windowname") && exists("g:tmux_panenumber")
    "             let b:tmux_sessionname = g:tmux_sessionname
    "             let b:tmux_windowname = g:tmux_windowname
    "             let b:tmux_panenumber = g:tmux_panenumber
    "         else
    "             call <SID>Tmux_Vars()
    "         end
    "     let target = b:tmux_sessionname . ":" . b:tmux_windowname . "." . b:tmux_panenumber
    "     end
    " else 
    "     let target = b:created_pane
    
    " Look, I know this is horrifying.  I'm sorry.
    "
    " THE PROBLEM: Certain REPLs (e.g.: SBCL) choke if you paste an assload of
    " text into them all at once (where 'assload' is 'something more than a few
    " hundred characters but fewer than eight thousand').  They'll seem to get out
    " of sync with the paste, and your code gets mangled.
    "
    " THE SOLUTION: We paste a single line at a time, and sleep for a bit in
    " between each one.  This gives the REPL time to process things and stay
    " caught up.  2 milliseconds seems to be enough of a sleep to avoid breaking
    " things and isn't too painful to sit through.
    "
    " This is my life.  This is computering in 2014.
    for line in split(a:text, '\n\zs' )
        call <SID>set_tmux_buffer(line)
        call system("tmux paste-buffer -dpt " . b:created_pane)
        sleep 2m
    endfor
endfunction

function! s:ensure_newlines(text)
    let text = a:text
    let trailing_newlines = matchstr(text, '\v\n*$')
    let spaces_to_add = g:tslime_ensure_trailing_newlines - strlen(trailing_newlines)
    
    while spaces_to_add > 0
      let spaces_to_add -= 1
      let text .= "\n"
    endwhile
    
    return text
endfunction

function! s:set_tmux_buffer(text)
    call system("tmux set-buffer -- '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
endfunction

function! SendToTmux(text)
    call Send_to_Tmux(s:ensure_newlines(a:text))
endfunction

function! SendToTmuxRaw(text)
    call Send_to_Tmux(a:text)
endfunction

"" Session completion
"function! Tmux_Session_Names(A,L,P)
"    return system("tmux list-sessions | sed -e 's/:.*$//'")
"endfunction
"
"" Window completion
"function! Tmux_Window_Names(A,L,P)
"	return system("tmux list-windows -t" . b:tmux_sessionname . ' | grep -e "^\w:" | sed -e "s/ \[[0-9x]*\]$//"')
"endfunction
"
"" Pane completion
"function! Tmux_Pane_Numbers(A,L,P)
"	return system("tmux list-panes -t " . b:tmux_sessionname . ":" . b:tmux_windowname . " | sed -e 's/:.*$//'")
"endfunction
"
" set tslime.vim variables
"function! s:Tmux_Vars()
"	let b:tmux_sessionname = ''
"	while b:tmux_sessionname == ''
"		let b:tmux_sessionname = input("session name: ", "", "custom,Tmux_Session_Names")
"	endwhile
"	let b:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')
"	let b:tmux_panenumber = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
"
"	if b:tmux_windowname == ''
"		let b:tmux_windowname = '0'
"	endif
"
"	if b:tmux_panenumber == ''
"		let b:tmux_panenumber = '0'
"	endif
"
"	let g:tmux_sessionname = b:tmux_sessionname
"	let g:tmux_windowname = b:tmux_windowname
"	let g:tmux_panenumber = b:tmux_panenumber
"endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"execute "vnoremap" . g:tslime_visual_mapping . ' "ry:call Send_to_Tmux(@r)<CR>'
"execute "nnoremap" . g:tslime_normal_mapping . ' vip"ry:call Send_to_Tmux(@r)<CR>'
"execute "nnoremap" . g:tslime_vars_mapping   . ' :call <SID>Tmux_Vars()<CR>'

execute "nnoremap" . g:tslime_create_pane    . ' :call <SID>Tmux_Create_Pane()<CR>'
execute "nnoremap" . g:tslime_send_line      . ' "rY:call Send_to_Tmux(@r)<CR>'
execute "nnoremap" . g:tslime_send_paragraph . ' vip"rY:call Send_to_Tmux(@r)<CR>'
execute "nnoremap" . g:tslime_send_all       . ' ggVG"ry:call Send_to_Tmux(@r)<CR>'
execute "vnoremap" . g:tslime_send_selected  . ' "rY:call Send_to_Tmux(@r)<CR>'

