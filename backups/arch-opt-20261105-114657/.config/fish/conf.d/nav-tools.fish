status is-interactive; or return

set -g DIRECT_FILE ~/.direct-map.tsv
set -g OPEN_FILE ~/.open-map.tsv
touch $DIRECT_FILE $OPEN_FILE

# ===== Shared helpers =====
function __map_lines -a file
    string match -r '.+' < $file
end

function __map_find -a file key
    set -l k (string lower -- "$key")
    for line in (__map_lines $file)
        set -l f (string split \t -- $line)
        if test (string lower -- "$f[1]") = "$k"; or contains -- $k (string split , -- $f[3])
            printf '%s\t%s\n' $f[1] $f[2]
            return 0
        end
    end
    return 1
end

function __map_remove -a file name
    set -l k (string lower -- "$name")
    set -l keep
    set -l found 0
    for line in (__map_lines $file)
        set -l f (string split \t -- $line)
        if test (string lower -- "$f[1]") = "$k"
            set found 1
        else
            set -a keep $line
        end
    end
    printf '%s\n' $keep > $file
    test $found -eq 1
end

function __map_add -a file name value
    set -l extra
    test (count $argv) -ge 4; and set extra $argv[4..-1]
    __map_remove $file $name
    printf '%s\t%s\t%s\n' $name $value (string join , -- (string lower -- $name) $extra) >> $file
end

function __map_list -a file
    set -l lines (__map_lines $file)
    set -l w 4
    for line in $lines
        set -l len (string length -- (string split -f1 \t -- $line))
        test $len -gt $w; and set w $len
    end
    set -l fmt "%-"(math $w + 4)"s%s\n"
    for line in $lines
        set -l f (string split \t -- $line)
        printf $fmt $f[1] $f[2]
    end
end

function __map_menu -a file empty_msg
    set -l lines (__map_lines $file)
    if test (count $lines) -eq 0
        printf '%s%s%s\n' (set_color yellow) $empty_msg (set_color normal) >&2
        return 1
    end
    set -l idx (__map_list $file | fzf --no-input --height=~60% --layout=reverse --border=none \
        --info=hidden --no-separator --no-scrollbar --pointer='>' --highlight-line --cycle \
        --color='bg+:#d0d4cc,fg+:#000000,pointer:#000000,gutter:-1' \
        --bind='tab:down,btab:up,enter:become(echo {n})')
    or return 1
    echo $lines[(math $idx + 1)]
end

function __map_complete -a file
    for line in (__map_lines $file)
        set -l f (string split \t -- $line)
        printf '%s\t%s\n' $f[1] $f[2]
    end
end

# ===== direct: saved folders =====
function direct -d "Jump to a saved folder (no name = menu)"
    if test (count $argv) -eq 0
        set -l sel (__map_menu $DIRECT_FILE "No paths saved. Use: direct-add")
        or return
        cd (string split -f2 \t -- $sel)
        return
    end
    set -l key (string join ' ' -- $argv)
    set -l m (__map_find $DIRECT_FILE $key)
    if test -n "$m"
        cd (string split -f2 \t -- $m)
    else if test -d "$key"
        cd $key
    else
        set_color red; echo "Unknown alias or path: $key"; set_color normal
        direct-list
    end
end

function direct-add -d "Save a folder: direct-add [name] [path] [alias...]"
    set -l name $argv[1]
    if test -z "$name"
        read -P "Name: " name
        test -z "$name"; and return 1
    end
    set -l path (pwd)
    test (count $argv) -ge 2; and set path $argv[2]
    set -l full (realpath -- $path 2>/dev/null)
    if not test -d "$full"
        set_color red; echo "Not a folder: $path"; set_color normal
        return 1
    end
    set -l extra
    test (count $argv) -ge 3; and set extra $argv[3..-1]
    __map_add $DIRECT_FILE $name $full $extra
    set_color green; echo "Added: $name → $full"; set_color normal
end

function direct-remove -d "Remove a saved folder"
    set -l name (string join ' ' -- $argv)
    test -z "$name"; and read -P "Name: " name
    if __map_remove $DIRECT_FILE $name
        set_color yellow; echo "Removed: $name"; set_color normal
    else
        set_color red; echo "Not found: $name"; set_color normal
    end
end

function direct-list -d "List saved folders"
    __map_list $DIRECT_FILE
end

# ===== open: saved links in Firefox =====
function __open_fix -a u
    if string match -qr '^[a-zA-Z][a-zA-Z0-9+.-]*://' -- $u
        echo $u
    else
        echo "https://$u"
    end
end

function __open_go -a name u
    printf '%s✔%s Opening %s (%s%s%s)...\n' (set_color green) (set_color normal) $name (set_color cyan) $u (set_color normal)
    if type -q firefox
        setsid -f firefox $u >/dev/null 2>&1
    else
        setsid -f xdg-open $u >/dev/null 2>&1
    end
end

function open -d "Open saved links (no name = menu)"
    if test (count $argv) -eq 0
        set -l sel (__map_menu $OPEN_FILE "No links saved. Use: open-add")
        or return
        set -l f (string split \t -- $sel)
        __open_go $f[1] $f[2]
        return
    end
    for n in $argv
        set -l m (__map_find $OPEN_FILE $n)
        if test -n "$m"
            set -l f (string split \t -- $m)
            __open_go $f[1] $f[2]
        else if test -e "$n"
            setsid -f xdg-open $n >/dev/null 2>&1
        else if string match -qr '\.|://' -- $n
            __open_go $n (__open_fix $n)
        else
            set_color red; echo "Unknown link: $n"; set_color normal
            open-list
        end
    end
end

function open-add -d "Save a link: open-add [name] [url] [alias...]"
    set -l name $argv[1]
    set -l url $argv[2]
    if test -z "$name"
        read -P "Name: " name
        test -z "$name"; and return 1
    end
    if test -z "$url"
        read -P "Url: " url
        test -z "$url"; and return 1
    end
    set -l extra
    test (count $argv) -ge 3; and set extra $argv[3..-1]
    set url (__open_fix $url)
    __map_add $OPEN_FILE $name $url $extra
    set_color green; echo "Added: $name → $url"; set_color normal
end

function open-remove -d "Remove a saved link"
    set -l name (string join ' ' -- $argv)
    test -z "$name"; and read -P "Name: " name
    if __map_remove $OPEN_FILE $name
        set_color yellow; echo "Removed: $name"; set_color normal
    else
        set_color red; echo "Not found: $name"; set_color normal
    end
end

function open-list -d "List saved links"
    __map_list $OPEN_FILE
end

# ===== Tab suggestions: name + path/url =====
complete -e -c direct
complete -e -c direct-remove
complete -e -c open
complete -e -c open-remove
complete -c direct -f -a '(__map_complete $DIRECT_FILE)'
complete -c direct-remove -f -a '(__map_complete $DIRECT_FILE)'
complete -c open -a '(__map_complete $OPEN_FILE)'
complete -c open-remove -f -a '(__map_complete $OPEN_FILE)'
