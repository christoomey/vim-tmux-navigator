" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to tmux.
" Additionally, <C-\> toggles between last active vim splits/tmux panes.

if exists("g:loaded_tmux_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_navigator = 1

" Originally by statox from here: https://vi.stackexchange.com/a/16250
function! HasNeighbor(direction)
    " Position of the current window
    let currentPosition = win_screenpos(winnr())

    if a:direction == 'k'
        " if we are looking for a top neigbour simply test if we are on the first line
        return currentPosition[0] != 1
    elseif a:direction == 'h'
        " if we are looking for a left neigbour simply test if we are on the first column
        return currentPosition[1] != 1
    endif

    " Number of windows on the screen
    let winNr = winnr('$')

    while winNr > 0
        " Get the position of each window
        let position = win_screenpos(winNr)
        let winNr = winNr - 1

        " Test for window on the right
        if ( a:direction == 'l' && ( currentPosition[1] + winwidth(0) ) < position[1] )
            return 1
        " Test for window on the bottom
        elseif ( a:direction == 'j' && ( currentPosition[0] + winheight(0) ) < position[0] )
            return 1
        endif
    endwhile
endfunction

function! s:VimNavigate(direction,...)
  let correct = get(a:, 1, 0)
  try
    " Check if we have a neighbor in the requested direction
    let hn = HasNeighbor(a:direction)
    let correctedDirection = a:direction
    if correct == 1 && a:direction == 'k' && hn == 0
      " If we go upwards and there is no neighbor, go left.
      let correctedDirection = 'h'
    elseif correct == 1 && a:direction == 'j' && hn == 0
      " If we go downwards and there is no neighbor, go right.
      let correctedDirection = 'l'
    endif
    execute 'wincmd ' . correctedDirection
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

if !get(g:, 'tmux_navigator_no_mappings', 0)
  nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
  nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
  nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
  nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
  nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>
endif

if empty($TMUX)
  command! TmuxNavigateLeft call s:VimNavigate('h')
  command! TmuxNavigateDown call s:VimNavigate('j')
  command! TmuxNavigateDownOrRight call s:VimNavigate('j', 1)
  command! TmuxNavigateUp call s:VimNavigate('k')
  command! TmuxNavigateUpOrLeft call s:VimNavigate('k', 1)
  command! TmuxNavigateRight call s:VimNavigate('l')
  command! TmuxNavigatePrevious call s:VimNavigate('p')
  finish
endif

command! TmuxNavigateLeft call s:TmuxAwareNavigate('h')
command! TmuxNavigateDown call s:TmuxAwareNavigate('j')
command! TmuxNavigateDownOrRight call s:TmuxAwareNavigate('j', 1)
command! TmuxNavigateUp call s:TmuxAwareNavigate('k')
command! TmuxNavigateUpOrLeft call s:TmuxAwareNavigate('k', 1)
command! TmuxNavigateRight call s:TmuxAwareNavigate('l')
command! TmuxNavigatePrevious call s:TmuxAwareNavigate('p')

if !exists("g:tmux_navigator_save_on_switch")
  let g:tmux_navigator_save_on_switch = 0
endif

if !exists("g:tmux_navigator_disable_when_zoomed")
  let g:tmux_navigator_disable_when_zoomed = 0
endif

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
endfunction

function! s:TmuxVimPaneIsZoomed()
  return s:TmuxCommand("display-message -p '#{window_zoomed_flag}'") == 1
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  let l:x=&shellcmdflag
  let &shellcmdflag='-c'
  let retval=system(cmd)
  let &shellcmdflag=l:x
  return retval
endfunction

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

let s:tmux_is_last_pane = 0
augroup tmux_navigator
  au!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
  if g:tmux_navigator_disable_when_zoomed && s:TmuxVimPaneIsZoomed()
    return 0
  endif
  return a:tmux_last_pane || a:at_tab_page_edge
endfunction

function! s:TmuxAwareNavigate(direction,...)
  let correct = get(a:, 1, 0)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
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

    let hn = HasNeighbor(a:direction)
    " Change the direction from top to left or from bottom to right as in
    " VimNavigate above if there is no neighbor in the requested direction.
    let args = 'select-pane -t ' . shellescape($TMUX_PANE) . ' -'
    if correct == 1 && a:direction == 'k' && hn == 0
      let args = args . 'L'
    elseif correct == 1 && a:direction == 'j' && hn == 0
      let args = args . 'R'
    else
      let args = args . tr(a:direction, 'phjkl', 'lLDUR')
    endif
    silent call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction
