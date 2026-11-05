status is-interactive; or return

function fish_greeting
    fastfetch --logo arch_small --logo-color-1 "38;2;23;147;209" --logo-color-2 "38;2;137;220;235"
end

# Tab: di -> direct | op -> open | direct/open -> menu | grey suggestion -> accept | else complete
# cd + Tab: show folders one per line
function __cd_pick
    set -l raw (commandline -ct)
    set -l tok (string unescape -- "$raw")
    set -l rawprefix (string replace -r '[^/]*$' '' -- "$raw")
    set -l prefix (string replace -r '[^/]*$' '' -- "$tok")
    set -l leaf (string replace -r '^.*/' '' -- "$tok")
    set -l base (string replace -r '^~' $HOME -- "$prefix")
    test -z "$base"; and set base .

    set -l names
    for d in $base/*/
        set -l n (path basename $d)
        if test -z "$leaf"; or string match -qi -- "$leaf*" $n
            set -a names $n
        end
    end

    set -l pick
    switch (count $names)
        case 0
            commandline -f complete
            return
        case 1
            set pick $names[1]
        case '*'
            set pick (printf '%s/\n' $names | fzf --no-input --height=~60% --layout=reverse --border=none \
                --info=hidden --no-separator --no-scrollbar --pointer='>' --highlight-line --cycle \
                --color='bg+:#d0d4cc,fg+:#000000,pointer:#000000,gutter:-1' \
                --bind='tab:down,btab:up')
            or begin
                commandline -f repaint
                return
            end
            set pick (string replace -r '/$' '' -- $pick)
    end
    commandline -t -- "$rawprefix"(string escape -- $pick)"/"
    commandline -f repaint
end

function __direct_tab
    set -l line (commandline)
    if string match -qr '^\s*(di|dir|dire|direc)$' -- "$line"
        commandline -r direct
    else if string match -qr '^\s*(op|ope)$' -- "$line"
        commandline -r open
    else if string match -qr '^\s*(direct|open)$' -- "$line"
        commandline -f execute
    else if string match -qr '^\s*(cd|pushd)\s' -- "$line"
        __cd_pick
    else
        commandline -f complete
    end
end
bind \t __direct_tab

# Show the list right after typing "direct " / "open "
function __suggest_check
    if string match -qr '^\s*(direct|open|direct-remove|open-remove) $' -- (commandline)
        commandline -f complete
    end
end
bind ' ' self-insert expand-abbr __suggest_check

# Tab on empty line or one word: pick an app from a list
function __app_pick
    set -l tok (string trim -- (commandline))
    set -l apps (printf "%s\n" $__gui_cmds $GUI_APPS telegram office jflex postman | sort -u)
    set -l matches
    for a in $apps
        if test -z "$tok"; or string match -qi -- "$tok*" $a
            set -a matches $a
        end
    end
    switch (count $matches)
        case 0
            commandline -f complete
            return
        case 1
            commandline -r "$matches[1] "
            commandline -f repaint
            return
    end
    set -l pick (printf "%s\n" $apps | fzf --prompt="Search app: " --query="$tok" --height=~60% --layout=reverse --border=none --info=hidden --no-separator --no-scrollbar --pointer=">" --highlight-line --cycle --color="bg+:#d0d4cc,fg+:#000000,pointer:#000000,gutter:-1" --bind="tab:down,btab:up")
    or begin
        commandline -f repaint
        return
    end
    commandline -r "$pick "
    commandline -f repaint
end

function __direct_tab
    set -l line (commandline)
    if string match -qr "^\s*(di|dir|dire|direc)\$" -- "$line"
        commandline -r direct
    else if string match -qr "^\s*(op|ope)\$" -- "$line"
        commandline -r open
    else if string match -qr "^\s*(direct|open)\$" -- "$line"
        commandline -f execute
    else if string match -qr "^\s*(cd|pushd)\s" -- "$line"
        __cd_pick
    else if string match -qr "^\s*\S*\$" -- "$line"
        __app_pick
    else
        commandline -f complete
    end
end
bind \t __direct_tab

# Remember every app you open (typed, picked from the list, or with run)
function __track_app --on-event fish_preexec
    set -l words (string split -n " " -- (string trim -- $argv[1]))
    set -l first $words[1]
    test "$first" = run; and set first $words[2]
    test -z "$first"; and return
    if contains -- $first $__gui_cmds $GUI_APPS telegram office jflex postman
        echo $first >> ~/.cache/app-usage
        if test (wc -l < ~/.cache/app-usage) -gt 500
            tail -n 200 ~/.cache/app-usage > ~/.cache/app-usage.tmp; and mv ~/.cache/app-usage.tmp ~/.cache/app-usage
        end
    end
end

# App list: recently used first, then the rest A-Z, with live search
function __app_pick
    set -l tok (string trim -- (commandline))
    set -l apps (printf "%s\n" $__gui_cmds $GUI_APPS telegram office jflex postman | sort -u)
    set -l recent
    if test -f ~/.cache/app-usage
        for a in (tac ~/.cache/app-usage | awk "!seen[\$0]++")
            contains -- $a $apps; and set -a recent $a
        end
    end
    set -l ordered $recent
    for a in $apps
        contains -- $a $recent; or set -a ordered $a
    end
    set -l pick (printf "%s\n" $ordered | fzf --prompt="Search app: " --query="$tok" --tiebreak=index --height=~60% --layout=reverse --border=none --info=hidden --no-separator --no-scrollbar --pointer=">" --highlight-line --cycle --color="bg+:#d0d4cc,fg+:#000000,pointer:#000000,gutter:-1" --bind="tab:down,btab:up")
    or begin
        commandline -f repaint
        return
    end
    commandline -r "$pick "
    commandline -f repaint
end

# Ordered app list: recently used first, then A-Z
function __app_ordered
    set -l apps (printf "%s\n" $__gui_cmds $GUI_APPS telegram office jflex postman | sort -u)
    set -l out
    if test -f ~/.cache/app-usage
        for a in (tac ~/.cache/app-usage | awk "!seen[\$0]++")
            contains -- $a $apps; and set -a out $a
        end
    end
    for a in $apps
        contains -- $a $out; or set -a out $a
    end
    printf "%s\n" $out
end

function __app_fzf -a query
    __app_ordered | fzf --prompt="Search app: " --query="$query" --tiebreak=index --height=~60% --layout=reverse --border=none --info=hidden --no-separator --no-scrollbar --pointer=">" --highlight-line --cycle --color="bg+:#d0d4cc,fg+:#000000,pointer:#000000,gutter:-1" --bind="tab:down,btab:up"
end

# "app" + Enter: pick an app and open it
function app
    set -l pick (__app_fzf "$argv")
    or return
    echo $pick >> ~/.cache/app-usage
    if functions -q $pick
        $pick
    else
        run $pick
    end
end

# Tab: "app" + Tab = app list; plus all the old Tab tricks
function __direct_tab
    set -l line (commandline)
    if string match -qr "^\s*app\$" -- "$line"
        set -l pick (__app_fzf "")
        and commandline -r "$pick "
        commandline -f repaint
    else if string match -qr "^\s*(di|dir|dire|direc)\$" -- "$line"
        commandline -r direct
    else if string match -qr "^\s*(op|ope)\$" -- "$line"
        commandline -r open
    else if string match -qr "^\s*(direct|open)\$" -- "$line"
        commandline -f execute
    else if string match -qr "^\s*(cd|pushd)\s" -- "$line"
        __cd_pick
    else if string match -qr "^\s*\S*\$" -- "$line"
        __app_pick
    else
        commandline -f complete
    end
end
bind \t __direct_tab

# Tab: app list ONLY after typing "app"; everything else = normal Tab
function __direct_tab
    set -l line (commandline)
    if string match -qr "^\s*app\$" -- "$line"
        set -l pick (__app_fzf "")
        and commandline -r "$pick "
        commandline -f repaint
    else if string match -qr "^\s*(di|dir|dire|direc)\$" -- "$line"
        commandline -r direct
    else if string match -qr "^\s*(op|ope)\$" -- "$line"
        commandline -r open
    else if string match -qr "^\s*(direct|open)\$" -- "$line"
        commandline -f execute
    else if string match -qr "^\s*(cd|pushd)\s" -- "$line"
        __cd_pick
    else
        commandline -f complete
    end
end
bind \t __direct_tab
