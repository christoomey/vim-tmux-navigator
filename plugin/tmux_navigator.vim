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

if !exists("g:tmux_navigator_zoom_out_navigation")
  let g:tmux_navigator_zoom_out_navigation = 0
endif

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
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
command! TmuxPaneCurrentCommand call s:TmuxPaneCurrentCommand()

let s:last_navigated_to = "vim"
augroup tmux_navigator
  au!
  autocmd WinEnter * let s:last_navigated_to = "vim"
augroup END

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

function! s:TmuxIsPaneZoomed()
    call system(s:TmuxOrTmateExecutable().' display -p "#{window_zoomed_flag}" | grep -q 1')
    return v:shell_error == 0
endfunction

function! s:TmuxAwareNavigate(direction)
  let is_toggling_to_tmux =  a:direction == 'p' && s:last_navigated_to == "tmux"
  let can_move_out_of_vim = s:TmuxIsPaneZoomed() ? g:tmux_navigator_zoom_out_navigation : 1 
  
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if is_toggling_to_tmux == 0 && s:VimNavigate(a:direction) == 1
    let s:last_navigated_to = "vim"
  elseif can_move_out_of_vim == 1
    call s:TmuxNavigate(a:direction)
    let s:last_navigated_to = "tmux"
  endif
endfunction

function! s:TmuxNavigate(direction)
  if g:tmux_navigator_save_on_switch == 1
    try
      update " save the active buffer. See :help update
    catch /^Vim\%((\a\+)\)\=:E32/ " catches the no file name error 
    endtry
  elseif g:tmux_navigator_save_on_switch == 2
    try
      wall " save all the buffers. See :help wall
    catch /^Vim\%((\a\+)\)\=:E141/ " catches the no file name error 
    endtry
  endif

  let args = 'select-pane -t ' . shellescape($TMUX_PANE) . ' -' . tr(a:direction, 'phjkl', 'lLDUR')
  silent call s:TmuxCommand(args)

  if s:NeedsVitalityRedraw()
    redraw!
  endif
endfunction

" returns `1` if navigated to another vim window, otherwise returns `0`
function! s:VimNavigate(direction)
  let nr = winnr()

  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry

  return nr != winnr()
endfunction

command! TmuxNavigateLeft call s:TmuxWinCmd('h')
command! TmuxNavigateDown call s:TmuxWinCmd('j')
command! TmuxNavigateUp call s:TmuxWinCmd('k')
command! TmuxNavigateRight call s:TmuxWinCmd('l')
command! TmuxNavigatePrevious call s:TmuxWinCmd('p')

if s:UseTmuxNavigatorMappings()
  nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
  nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
  nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
  nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
  nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>
endif
