status is-interactive; or return

set -g DIRECT_FILE ~/.direct-map.tsv
test -f $DIRECT_FILE; or touch $DIRECT_FILE

# ===== Disk bar (type "disk" to see it) =====
function disk
    set_color yellow; echo -n " [DISK] "; set_color normal
    for row in (df --output=source,target,pcent -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs 2>/dev/null | tail -n +2 | awk '!seen[$1]++')
        set -l f (string split -n ' ' -- $row)
        set -l pct (string replace '%' '' -- $f[3])
        string match -qr '^\d+$' -- $pct; or continue
        if test $pct -gt 90
            set_color red
        else if test $pct -gt 70
            set_color yellow
        else
            set_color green
        end
        echo -n "$f[2] ($pct%) "
    end
    set_color normal
    echo
end

# ===== Direct =====
function __direct_lines
    string match -r '.+' < $DIRECT_FILE
end

function __direct_find -a key
    for line in (__direct_lines)
        set -l f (string split \t -- $line)
        if test "$f[1]" = "$key"; or contains -- $key (string split , -- $f[3])
            echo $f[2]
            return 0
        end
    end
    return 1
end

function __direct_remove_quiet -a name
    set -l keep
    for line in (__direct_lines)
        set -l f (string split \t -- $line)
        test "$f[1]" = "$name"; or set -a keep $line
    end
    printf '%s\n' $keep > $DIRECT_FILE
end

function __direct_menu
    set -l items
    for line in (__direct_lines)
        set -l f (string split \t -- $line)
        set -a items (printf '%-10s\t%s' $f[1] $f[2])
    end
    if test (count $items) -eq 0
        set_color yellow; echo "No paths saved. Use: direct-add name path"; set_color normal
        return 1
    end
    set -l pick (printf '%s\n' $items | fzf --height=~50% --reverse --info=hidden --cycle --delimiter=\t --bind=tab:down,btab:up)
    or return 1
    string split -f2 \t -- $pick
end

function direct
    set -l key $argv[1]
    if test -z "$key"
        set -l sel (__direct_menu)
        or return
        cd $sel
        return
    end
    set -l p (__direct_find $key)
    if test -n "$p"
        cd $p
    else if test -d "$key"
        cd $key
    else
        set_color red; echo "Unknown alias or path: $key"; set_color normal
        direct-list
    end
end

function direct-add
    if test (count $argv) -lt 1
        echo "Usage: direct-add name [path] [alias...]"
        return 1
    end
    set -l name $argv[1]
    set -l path (pwd)
    test (count $argv) -ge 2; and set path $argv[2]
    set -l extra
    test (count $argv) -ge 3; and set extra $argv[3..-1]
    set -l full (realpath -- $path 2>/dev/null)
    if not test -d "$full"
        set_color red; echo "Not a folder: $path"; set_color normal
        return 1
    end
    __direct_remove_quiet $name
    printf '%s\t%s\t%s\n' $name $full (string join , -- (string lower -- $name) $extra) >> $DIRECT_FILE
    set_color green; echo "Added: $name -> $full"; set_color normal
end

function direct-remove
    __direct_remove_quiet $argv[1]
    set_color yellow; echo "Removed: $argv[1]"; set_color normal
end

function direct-list
    for line in (__direct_lines)
        set -l f (string split \t -- $line)
        printf '%-10s %s\n' $f[1] $f[2]
    end
end

function __direct_complete
    for line in (__direct_lines)
        set -l f (string split \t -- $line)
        printf '%s\t%s\n' $f[1] $f[2]
    end
end
complete -c direct -f -a '(__direct_complete)'
complete -c direct-remove -f -a '(__direct_complete)'

# ===== Tab: di/dir/dire/direc -> direct | op/ope -> open | direct/open -> menu =====
function __direct_tab
    set -l line (commandline)
    if string match -qr '^\s*(di|dir|dire|direc)$' -- "$line"
        commandline -r direct
    else if string match -qr '^\s*(op|ope)$' -- "$line"
        commandline -r open
    else if string match -qr '^\s*(direct|url)$' -- "$line"
        commandline -f execute
    else
        commandline -f complete
    end
end
bind \t __direct_tab

# ===== unzip / specs / ll / ptime =====
function unzip
    argparse 'd/dest=' -- $argv; or return 1
    set -l zip (realpath -- $argv[1])
    or return 1
    set -l dest $_flag_dest
    test -z "$dest"; and set dest (pwd)/(path change-extension '' (path basename $zip))
    mkdir -p $dest
    if bsdtar -xf $zip -C $dest
        set_color green; echo "Extracted to: $dest"; set_color normal
    end
end

function specs
    fastfetch
end

function ll
    ls -lah --color=auto --group-directories-first $argv
end

function ptime
    set -l t0 (date +%s%N)
    fish -i -c exit >/dev/null 2>&1
    set -l t1 (date +%s%N)
    echo "Startup: "(math -s0 "($t1 - $t0) / 1000000")" ms"
end
