Vim Tmux Navigator
==================

This plugin is a repackaging of [Mislav Marohnić's][] tmux-navigator
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

### tmux

To configure the tmux side of this customization there are two options:

#### Add a snippet

Add the following to your `~/.tmux.conf` file:

``` tmux
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
bind-key -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
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

nnoremap <silent> {Left-Mapping} :TmuxNavigateLeft<cr>
nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>
```

*Note* Each instance of `{Left-Mapping}` or `{Down-Mapping}` must be replaced
in the above code with the desired mapping. Ie, the mapping for `<ctrl-h>` =>
Left would be created with `nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>`.

##### Autosave on leave

You can configure the plugin to write the current buffer, or all buffers, when navigating from Vim to tmux. This functionality is exposed via the `g:tmux_navigator_save_on_switch` variable, which can have either of the following values:

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

#### Tmux

Alter each of the five lines of the tmux configuration listed above to use your
custom mappings. **Note** each line contains two references to the desired
mapping.

### Additional Customization

#### Restoring Clear Screen (C-l)

The default key bindings include `<Ctrl-l>` which is the readline key binding
for clearing the screen. The following binding can be added to your `~/.tmux.conf` file to provide an alternate mapping to `clear-screen`.

``` tmux
bind C-l send-keys 'C-l'
```

With this enabled you can use `<prefix> C-l` to clear the screen.

Thanks to [Brian Hogan][] for the tip on how to re-map the clear screen binding.

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

Troubleshooting
---------------

### Vim -> Tmux doesn't work!

This is likely due to conflicting key mappings in your `~/.vimrc`. You can use
the following search pattern to find conflicting mappings
`\vn(nore)?map\s+\<c-[hjkl]\>`. Any matching lines should be deleted or
altered to avoid conflicting with the mappings from the plugin.

Another option is that the pattern matching included in the `.tmux.conf` is
not recognizing that Vim is active. To check that tmux is properly recognizing
Vim, use the provided Vim command `:TmuxPaneCurrentCommand`. The output of
that command should be a string like 'vim', 'Vim', 'vimdiff', etc. If you
encounter a different output please [open an issue][] with as much info about
your OS, Vim version, and tmux version as possible.

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

### It Doesn't Work in tmate

[tmate][] is a tmux fork that aids in setting up remote pair programming
sessions. It is designed to run alongside tmux without issue, but occasionally
there are hiccups. Specifically, if the versions of tmux and tmate don't match,
you can have issues. See [this
issue](https://github.com/christoomey/vim-tmux-navigator/issues/27) for more
detail.

[tmate]: http://tmate.io/

### It Doesn't Work in Neovim (specifically C-h)

[Neovim][] is a Vim fork. While Neovim is intended to be a drop-in replacement
for Vim, it does handle some keyboard input differently than Vim does. Some
users (including those on OS X) may find that all of their pane-switching
keybindings work with the exception of <kbd>Ctrl</kbd>+<kbd>h</kbd>, which
instead returns a backspace. The explanation of what is going on vastly exceeds
the scope of this guide, but you can read the discussion on this Neovim
[issue][].

The simplest and hackiest solution is to add the following to your Neovim
`init.vim`, capturing the <kbd>Backspace</kbd> that Neovim receives when
<kbd>Ctrl</kbd>+<kbd>h</kbd> is typed in normal mode:

```vimL
nnoremap <silent> <BS> :TmuxNavigateLeft<cr>
```

A more complete and less-hacky solution would be to update the incorrect
terminfo entry that is part of the problem on OS X (and some Linux
distributions) as described in this [comment][].

[Neovim]: https://neovim.io/
[issue]: https://github.com/neovim/neovim/issues/2048
[comment]: https://github.com/neovim/neovim/issues/2048#issuecomment-78045837

### It Still Doesn't Work!!!

The tmux configuration uses an inlined grep pattern match to help determine if
the current pane is running Vim. If you run into any issues with the navigation
not happening as expected, you can try using [Mislav's original external
script][] which has a more robust check.

[Brian Hogan]: https://twitter.com/bphogan
[Mislav Marohnić's]: http://mislav.uniqpath.com/
[Mislav's original external script]: https://github.com/mislav/dotfiles/blob/master/bin/tmux-vim-select-pane
[Vundle]: https://github.com/gmarik/vundle
[TPM]: https://github.com/tmux-plugins/tpm
[configuration section below]: #custom-key-bindings
[this blog post]: http://www.codeography.com/2013/06/19/navigating-vim-and-tmux-splits
[this gist]: https://gist.github.com/mislav/5189704
