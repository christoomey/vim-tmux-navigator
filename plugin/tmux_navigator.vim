" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to tmux.
" Additionally, <C-\> toggles between last active vim splits/tmux panes.

if exists("g:loaded_tmux_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_navigator = 1

if !exists("g:tmux_navigator_save_on_switch")
  let g:tmux_navigator_save_on_switch = 0
endif

function! s:TmuxOrTmateExecutable()
  if s:StrippedSystemCall("[[ $TMUX == *'tmate'* ]] && echo 'tmate'") == 'tmate'
    return "tmate"
  else
    return "tmux"
  endif
endfunction

function! s:StrippedSystemCall(system_cmd)
  let raw_result = system(a:system_cmd)
  return substitute(raw_result, '^\s*\(.\{-}\)\s*\n\?$', '\1', '')
endfunction

function! s:UseTmuxNavigatorMappings()
  return !get(g:, 'tmux_navigator_no_mappings', 0)
endfunction

function! s:InTmuxSession()
  return $TMUX != ''
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  return system(cmd)
endfunction

function! s:TmuxPaneCurrentCommand()
  echo s:TmuxCommand("display-message -p '#{pane_current_command}'")
endfunction
command! TmuxPaneCurrentCommand call <SID>TmuxPaneCurrentCommand()

let s:tmux_is_last_pane = 0
au WinEnter * let s:tmux_is_last_pane = 0

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! s:TmuxWinCmd(direction)
  if s:InTmuxSession()
    call s:TmuxAwareNavigate(a:direction)
  else
    call s:VimNavigate(a:direction)
  endif
endfunction

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:TmuxAwareNavigate(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimNavigate(a:direction)
  endif
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if tmux_last_pane || nr == winnr()
    if g:tmux_navigator_save_on_switch
      update
    endif
    let args = 'select-pane -' . tr(a:direction, 'phjkl', 'lLDUR')
    silent call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

command! TmuxNavigateLeft call <SID>TmuxWinCmd('h')
command! TmuxNavigateDown call <SID>TmuxWinCmd('j')
command! TmuxNavigateUp call <SID>TmuxWinCmd('k')
command! TmuxNavigateRight call <SID>TmuxWinCmd('l')
command! TmuxNavigatePrevious call <SID>TmuxWinCmd('p')

if s:UseTmuxNavigatorMappings()
  nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
  nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
  nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
  nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
  nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>
endif
