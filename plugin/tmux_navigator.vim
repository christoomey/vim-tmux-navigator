" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to tmux.
" Additionally, <C-\> toggles between last active vim splits/tmux panes.

if exists("g:loaded_tmux_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_navigator = 1

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
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
  command! TmuxNavigateUp call s:VimNavigate('k')
  command! TmuxNavigateRight call s:VimNavigate('l')
  command! TmuxNavigatePrevious call s:VimNavigate('p')
  finish
endif

command! TmuxNavigateLeft call s:TmuxAwareNavigate('h')
command! TmuxNavigateDown call s:TmuxAwareNavigate('j')
command! TmuxNavigateUp call s:TmuxAwareNavigate('k')
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
  return s:TmuxCommand(['display-message', '-p', '#{window_zoomed_flag}']) == 1
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:GetTmuxCommand(args)
  return [s:TmuxOrTmateExecutable(), '-S', s:TmuxSocket()] + a:args
endfunction

if has('nvim')
  function! s:TmuxCommand(args)
    return substitute(system(s:GetTmuxCommand(a:args)), '\n$', '', '')
  endfunction
else
  function! s:TmuxCommand(args)
    " Vim does not support a list for `system()`.
    let cmd = join(map(s:GetTmuxCommand(a:args), 'fnameescape(v:val)'))
    return substitute(system(cmd), '\n$', '', '')
  endfunction
endif

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand(['run-shell', "ps -o state= -o comm= -t '#{pane_tty}'"])
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

function! s:TmuxAwareNavigate(direction)
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
    let args = ['select-pane', '-t', $TMUX_PANE, '-'.tr(a:direction, 'phjkl', 'lLDUR')]
    call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction

" Indicate to tmux keybindings that we handle $TMUX_PANE.
if exists('*jobstart')
  function! s:setup_indicator() abort
    call call('jobstart', [s:GetTmuxCommand(['set', '-a', '@tmux_navigator', '-'.$TMUX_PANE.'-'])])
  endfunction
elseif exists('*job_start')
  function! s:setup_indicator() abort
    call call('job_start', [s:GetTmuxCommand(['set', '-a', '@tmux_navigator', '-'.$TMUX_PANE.'-'])])
  endfunction
else
  function! s:setup_indicator() abort
    call s:TmuxCommand(['set', '-a', '@tmux_navigator', '-'.$TMUX_PANE.'-'])
  endfunction
endif

function! s:get_indicator() abort
  return s:TmuxCommand(['show', '-v', '@tmux_navigator'])
endfunction
command! TmuxNavigatorPaneIndicator echo s:get_indicator()

function! s:remove_indicator() abort
  let cur = s:get_indicator()
  " Remove indicators globally (especially important with nested Vim in :term).
  let new = substitute(cur, '-'.$TMUX_PANE.'-', '', 'g')
  call s:TmuxCommand(['set', '@tmux_navigator', new])
endfunction

augroup tmux_navigator
  autocmd VimEnter * call s:setup_indicator()
  autocmd VimLeave * call s:remove_indicator()
  if exists('##VimSuspend')
    autocmd VimSuspend * call s:remove_indicator()
    autocmd VimResume * call s:setup_indicator()
  endif
augroup END
