Vim Tmux Navigator
==================

This plugin is a repackaging of [Mislav Marohnić's](https://mislav.net/) tmux-navigator
configuration described in [this gist][]. When combined with a set of tmux
key bindings, the plugin will allow you to navigate seamlessly between
vim and tmux splits using a consistent set of hotkeys.

**NOTE**: This requires tmux v1.8 or higher.

Usage
-----

This plugin provides the following mappings which allow you to move between
Vim panes and tmux splits seamlessly.

- `<ctrl-h>` => Left
- `<ctrl-j>` => Down
- `<ctrl-k>` => Up
- `<ctrl-l>` => Right
- `<ctrl-\>` => Previous split

**Note** - you don't need to use your tmux `prefix` key sequence before using
the mappings.

If you want to use alternate key mappings, see the [configuration section
below][].

Installation
------------

### Vim

If you don't have a preferred installation method, I recommend using [Vundle][].
Assuming you have Vundle installed and configured, the following steps will
install the plugin:

Add the following line to your `~/.vimrc` file

``` vim
Plugin 'christoomey/vim-tmux-navigator'
```

Then run

```
:PluginInstall
```

If you are using Vim 8+, you don't need any plugin manager. Simply clone this repository inside `~/.vim/pack/plugin/start/` directory and restart Vim.

```
git clone git@github.com:christoomey/vim-tmux-navigator.git ~/.vim/pack/plugins/start/vim-tmux-navigator
```

### lazy.nvim

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim). Add the following plugin to your configuration.

```lua
{
  "christoomey/vim-tmux-navigator",
  event = "Very Lazy",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
```

Then, restart Neovim and lazy.nvim will automatically install the plugin and configure the keybindings.

### tmux

To configure the tmux side of this customization there are two options:

#### Add a snippet

Add the following to your `~/.tmux.conf` file:

``` tmux
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l
```

#### TPM

If you'd prefer, you can use the Tmux Plugin Manager ([TPM][]) instead of
copying the snippet.
When using TPM, add the following lines to your ~/.tmux.conf:

``` tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
run '~/.tmux/plugins/tpm/tpm'
```

Thanks to Christopher Sexton who provided the updated tmux configuration in
[this blog post][].

Configuration
-------------

### Custom Key Bindings

If you don't want the plugin to create any mappings, you can use the five
provided functions to define your own custom maps. You will need to define
custom mappings in your `~/.vimrc` as well as update the bindings in tmux to
match.

#### Vim

Add the following to your `~/.vimrc` to define your custom maps:

``` vim
let g:tmux_navigator_no_mappings = 1

noremap <silent> {Left-Mapping} :<C-U>TmuxNavigateLeft<cr>
noremap <silent> {Down-Mapping} :<C-U>TmuxNavigateDown<cr>
noremap <silent> {Up-Mapping} :<C-U>TmuxNavigateUp<cr>
noremap <silent> {Right-Mapping} :<C-U>TmuxNavigateRight<cr>
noremap <silent> {Previous-Mapping} :<C-U>TmuxNavigatePrevious<cr>
```

*Note* Each instance of `{Left-Mapping}` or `{Down-Mapping}` must be replaced
in the above code with the desired mapping. Ie, the mapping for `<ctrl-h>` =>
Left would be created with `noremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>`.

##### Autosave on leave

You can configure the plugin to write the current buffer, or all buffers, when
navigating from Vim to tmux. This functionality is exposed via the
`g:tmux_navigator_save_on_switch` variable, which can have either of the
following values:

Value  | Behavior
------ | ------
1      | `:update` (write the current buffer, but only if changed)
2      | `:wall` (write all buffers)

To enable this, add the following (with the desired value) to your ~/.vimrc:

```vim
" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2
```

##### Disable While Zoomed

By default, if you zoom the tmux pane running Vim and then attempt to navigate
"past" the edge of the Vim session, tmux will unzoom the pane. This is the
default tmux behavior, but may be confusing if you've become accustomed to
navigation "wrapping" around the sides due to this plugin.

We provide an option, `g:tmux_navigator_disable_when_zoomed`, which can be used
to disable this unzooming behavior, keeping all navigation within Vim until the
tmux pane is explicitly unzoomed.

To disable navigation when zoomed, add the following to your ~/.vimrc:

```vim
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1
```

##### Preserve Zoom

As noted above, navigating from a Vim pane to another tmux pane normally causes
the window to be unzoomed. Some users may prefer the behavior of tmux's `-Z`
option to `select-pane`, which keeps the window zoomed if it was zoomed. To
enable this behavior, set the `g:tmux_navigator_preserve_zoom` option to `1`:

```vim
" If the tmux window is zoomed, keep it zoomed when moving from Vim to another pane
let g:tmux_navigator_preserve_zoom = 1
```

Naturally, if `g:tmux_navigator_disable_when_zoomed` is enabled, this option
will have no effect.

#### Tmux

Alter each of the five lines of the tmux configuration listed above to use your
custom mappings. **Note** each line contains two references to the desired
mapping.

### Additional Customization

#### Ignoring programs that use Ctrl+hjkl movement

In interactive programs such as FZF, Ctrl+hjkl can be used instead of the arrow keys to move the selection up and down. If vim-tmux-navigator is getting in your way trying to change the active window instead, you can make it be ignored and work as if this plugin were not enabled. Just modify the `is_vim` variable(that you have either on the snipped you pasted on `~/.tmux.conf` or on the `vim-tmux-navigator.tmux` file). For example, to add the program `foobar`:

```diff
- is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
+ is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|foobar)(diff)?$'"
```

#### Restoring Clear Screen (C-l)

The default key bindings include `<Ctrl-l>` which is the readline key binding
for clearing the screen. The following binding can be added to your `~/.tmux.conf` file to provide an alternate mapping to `clear-screen`.

``` tmux
bind C-l send-keys 'C-l'
```

With this enabled you can use `<prefix> C-l` to clear the screen.

Thanks to [Brian Hogan][] for the tip on how to re-map the clear screen binding.

#### Restoring SIGQUIT (C-\\)

The default key bindings also include `<Ctrl-\>` which is the default method of
sending SIGQUIT to a foreground process. Similar to "Clear Screen" above, a key
binding can be created to replicate SIGQUIT in the prefix table.

``` tmux
bind C-\\ send-keys 'C-\'
```

Alternatively, you can exclude the previous pane key binding from your `~/.tmux.conf`. If using TPM, the following line can be used to unbind the previous pane binding set by the plugin.

``` tmux
unbind -n C-\\
```

#### Disable Wrapping

By default, if you try to move past the edge of the screen, tmux/vim will
"wrap" around to the opposite side. To disable this, you'll need to
configure both tmux and vim:

For vim, you only need to enable this option:
```vim
let  g:tmux_navigator_no_wrap = 1
```

Tmux doesn't have an option, so whatever key bindings you have need to be set
to conditionally wrap based on position on screen:

```tmux
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {} { select-pane -L } }
bind-key -n 'C-j' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}' {} { select-pane -D } }
bind-key -n 'C-k' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'    {} { select-pane -U } }
bind-key -n 'C-l' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'  {} { select-pane -R } }

bind-key -T copy-mode-vi 'C-h' if-shell -F '#{pane_at_left}'   {} { select-pane -L }
bind-key -T copy-mode-vi 'C-j' if-shell -F '#{pane_at_bottom}' {} { select-pane -D }
bind-key -T copy-mode-vi 'C-k' if-shell -F '#{pane_at_top}'    {} { select-pane -U }
bind-key -T copy-mode-vi 'C-l' if-shell -F '#{pane_at_right}'  {} { select-pane -R }
```

#### Nesting
If you like to nest your tmux sessions, this plugin is not going to work
properly. It probably never will, as it would require detecting when Tmux would
wrap from one outermost pane to another and propagating that to the outer
session.

By default this plugin works on the outermost tmux session and the vim
sessions it contains, but you can customize the behaviour by adding more
commands to the expression used by the grep command.

When nesting tmux sessions via ssh or mosh, you could extend it to look like
`'(^|\/)g?(view|vim|ssh|mosh?)(diff)?$'`, which makes this plugin work within
the innermost tmux session and the vim sessions within that one. This works
better than the default behaviour if you use the outer Tmux sessions as relays
to different hosts and have all instances of vim on remote hosts.

Similarly, if you like to nest tmux locally, add `|tmux` to the expression.

This behaviour means that you can't leave the innermost session with Ctrl-hjkl
directly. These following fallback mappings can be targeted to the right Tmux
session by escaping the prefix (Tmux' `send-prefix` command).

``` tmux
bind -r C-h run "tmux select-pane -L"
bind -r C-j run "tmux select-pane -D"
bind -r C-k run "tmux select-pane -U"
bind -r C-l run "tmux select-pane -R"
bind -r C-\ run "tmux select-pane -l"
```

Another workaround is to configure tmux on the outer machine to send keys to
the inner tmux session:

```
bind-key -n 'M-h' 'send-keys c-h'
bind-key -n 'M-j' 'send-keys c-j'
bind-key -n 'M-k' 'send-keys c-k'
bind-key -n 'M-l' 'send-keys c-l'
```

Here we bind "meta" key (aka "alt" or "option" key) combinations for each of
the four directions and send those along to the innermost session via
`send-keys`. You use the normal `C-h,j,k,l` while in the outermost session and
the alternative bindings to navigate the innermost session. Note that if you
use the example above on a Mac, you may need to configure your terminal app to
get the option key to work like a normal meta key. Consult your terminal app's
manual for details.

A third possible solution is to manually prevent the outermost tmux session
from intercepting the navigation keystrokes by disabling the prefix table:

```
set -g pane-active-border-style 'fg=#000000,bg=#ffff00'
bind -T root F12  \
  set prefix None \;\
  set key-table off \;\
  if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
  set -g pane-active-border-style 'fg=#000000,bg=#00ff00'
  refresh-client -S \;\

bind -T off F12 \
  set -u prefix \;\
  set -u key-table \;\
  set -g pane-active-border-style 'fg=#000000,bg=#ffff00'
  refresh-client -S
```

This code, added to the machine running the outermost tmux session, toggles the
outermost prefix table on and off with the `F12` key. When off, the active
pane's border changes to green to indicate that the inner session receives
navigation keystrokes. When toggled back on, the border returns to yellow and
normal operation resumes and the outermost responds to the nav keystrokes.

The code example above also toggles the prefix key (ctrl-b by default) for the
outer session so that same prefix can be temporarily used on the inner session
instead of having to use a different prefix (ctrl-a by default) which you may
find convenient. If not, simply remove the lines that set/unset the prefix key
from the code example above.


Troubleshooting
---------------

### Vim -> Tmux doesn't work!

This is likely due to conflicting key mappings in your `~/.vimrc`. You can use
the following search pattern to find conflicting mappings
`\v(nore)?map\s+\<c-[hjkl]\>`. Any matching lines should be deleted or
altered to avoid conflicting with the mappings from the plugin.

Another option is that the pattern matching included in the `.tmux.conf` is
not recognizing that Vim is active. To check that tmux is properly recognizing
Vim, use the provided Vim command `:TmuxNavigatorProcessList`. The output of
that command should be a list like:

```
Ss   -zsh
S+   vim
S+   tmux
```

If you encounter a different output please [open an issue][] with as much info
about your OS, Vim version, and tmux version as possible.

[open an issue]: https://github.com/christoomey/vim-tmux-navigator/issues/new

### Tmux Can't Tell if Vim Is Active

This functionality requires tmux version 1.8 or higher. You can check your
version to confirm with this shell command:

``` bash
tmux -V # should return 'tmux 1.8'
```

### Switching out of Vim Is Slow

If you find that navigation within Vim (from split to split) is fine, but Vim
to a non-Vim tmux pane is delayed, it might be due to a slow shell startup.
Consider moving code from your shell's non-interactive rc file (e.g.,
`~/.zshenv`) into the interactive startup file (e.g., `~/.zshrc`) as Vim only
sources the non-interactive config.

### It doesn't work in Vim's `terminal` mode

Terminal mode is currently unsupported as adding this plugin's mappings there
causes conflict with movement mappings for FZF (it also uses terminal mode).
There's a conversation about this in https://github.com/christoomey/vim-tmux-navigator/pull/172

### It Doesn't Work in tmate

[tmate][] is a tmux fork that aids in setting up remote pair programming
sessions. It is designed to run alongside tmux without issue, but occasionally
there are hiccups. Specifically, if the versions of tmux and tmate don't match,
you can have issues. See [this
issue](https://github.com/christoomey/vim-tmux-navigator/issues/27) for more
detail.

[tmate]: http://tmate.io/

### Switching between host panes doesn't work when docker is running

Images built from minimalist OSes may not have the `ps` command or have a
simpler version of the command that is not compatible with this plugin.
Try installing the `procps` package using the appropriate package manager
command. For Alpine, you would do `apk add procps`.

If this doesn't solve your problem, you can also try the following:

Replace the `is_vim` variable in your `~/.tmux.conf` file with:
```tmux
if-shell '[ -f /.dockerenv ]' \
  "is_vim=\"ps -o state=,comm= -t '#{pane_tty}' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'\""
  # Filter out docker instances of nvim from the host system to prevent
  # host from thinking nvim is running in a pseudoterminal when its not.
  "is_vim=\"ps -o state=,comm=,cgroup= -t '#{pane_tty}' \
      | grep -ivE '^.+ +.+ +.+\\/docker\\/.+$' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)? +'\""
```

Details: The output of the ps command on the host system includes processes
running within containers, but containers have their own instances of
/dev/pts/\*. vim-tmux-navigator relies on /dev/pts/\* to determine if vim is
running, so if vim is running in say /dev/pts/<N> in a container and there is a
tmux pane (not running vim) in /dev/pts/<N> on the host system, then without
the patch above vim-tmux-navigator will think vim is running when its not.

### It Still Doesn't Work!!!

The tmux configuration uses an inlined grep pattern match to help determine if
the current pane is running Vim. If you run into any issues with the navigation
not happening as expected, you can try using [Mislav's original external
script][] which has a more robust check.

[Brian Hogan]: https://twitter.com/bphogan
[Mislav's original external script]: https://github.com/mislav/dotfiles/blob/master/bin/tmux-vim-select-pane
[Vundle]: https://github.com/gmarik/vundle
[TPM]: https://github.com/tmux-plugins/tpm
[configuration section below]: #custom-key-bindings
[this blog post]: http://www.codeography.com/2013/06/19/navigating-vim-and-tmux-splits
[this gist]: https://gist.github.com/mislav/5189704
