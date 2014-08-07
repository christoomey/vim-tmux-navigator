Vim Tmux Navigator
==================

This plugin is based on [Mislav Marohnić's][] tmux-navigator configuration
described in [this gist][]. When combined with a set of tmux key bindings, the
plugin will allow you to navigate seamlessly between Vim and tmux splits using
a consistent set of hotkeys.

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

### Tmux

Add the following to your `tmux.conf` file to configure the tmux side of
this customization.

``` tmux
# Smart pane switching with awareness of vim splits
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim='tmux show-env tmux_navigator_bypass_#{pane_id} >/dev/null 2>&1 \
  || echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?x?)(diff)?$"'
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
bind -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
```

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

nnoremap <silent> {Left-mapping} :TmuxNavigateLeft<cr>
nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>
```

*Note* Each instance of `{Left-Mapping}` or `{Down-Mapping}` must be replaced
in the above code with the desired mapping. Ie, the mapping for `<ctrl-h>` =>
Left would be created with `nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>`.


##### Autosave on leave

    let g:tmux_navigator_save_on_switch = 1

This will execute the update command on leaving vim to a tmux pane. Default is Zero


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

The Vim plugin provides a command to output the tmux environment variable which
is used for communication between Vim and tmux: `:TmuxPaneShowEnvVar`.

Its output should look similar to this:

    TMUX_PANE: %1
    tmux_navigator_bypass_%1=1

If you encounter a different output please [open an issue][] with as much info
about your OS, Vim version, and tmux version as possible.

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

### It Still Doesn't Work!!!

You can try using [Mislav's original external script][], but please consider
[opening an issue][open an issue] to get it fixed in this plugin, which is
meant to use a more robust method.

How does it work?
-----------------
This plugin uses a tmux environment variable for communication between tmux and
Vim. This environment variable (`tmux_navigator_bypass_#{pane_id}`) contains
the tmux pane identifier (available as `$TMUX_PANE` in the shell environment).

`show-env` is used in the tmux keybindings to see if Vim has indicated that it
is running inside the current pane.

The Vim plugin uses `tmux set-env` to set the environment variable during
startup and unsets it when exiting.


[Brian Hogan]: https://twitter.com/bphogan
[Mislav Marohnić's]: http://mislav.uniqpath.com/
[Mislav's original external script]: https://github.com/mislav/dotfiles/blob/master/bin/tmux-vim-select-pane
[Vundle]: https://github.com/gmarik/vundle
[configuration section below]: #custom-key-bindings
[this gist]: https://gist.github.com/mislav/5189704
[open an issue]: https://github.com/christoomey/vim-tmux-navigator/issues/new
