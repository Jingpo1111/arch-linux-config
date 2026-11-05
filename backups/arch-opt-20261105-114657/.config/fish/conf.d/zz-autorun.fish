status is-interactive; or return

# Commands that must always stay in the terminal
set -g __gui_exclude java javac python python3 node npm git ssh mysql psql nano vim nvim htop btop kitty foot sudo env sh bash fish

# Build (or reuse) the list of desktop apps from the app launcher entries
function __gui_cmds_build
    set -l cache ~/.cache/gui-cmds
    if not test -f $cache; or test (math (date +%s) - (path mtime $cache)) -gt 86400
        mkdir -p ~/.cache
        awk -F= 'FNR==1{t=0;n=0;e=""} /^Terminal=true/{t=1} /^NoDisplay=true/{n=1} /^Exec=/ && e==""{e=$2} ENDFILE{ if(!t && !n && e!=""){ split(e,a," "); sub(".*/","",a[1]); print a[1] } }' \
            /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null | sort -u > $cache
    end
    set -g __gui_cmds (cat $cache)
end
__gui_cmds_build

# Enter: if the command is a desktop app, open it with "run" (new desktop, detached)
function __gui_enter
    if commandline --paging-mode
        commandline -f execute
        return
    end
    set -l line (string trim -- (commandline))
    set -l first (string split -n ' ' -- $line)[1]
    if test -n "$first"
        and not string match -q -r '[|;&<>]' -- $line
        and contains -- $first $__gui_cmds
        and not contains -- $first $__gui_exclude
        and not functions -q $first
        commandline -r "run $line"
    end
    commandline -f execute
end
bind \r __gui_enter

# After installing a new app, run "guirefresh" so it is recognized
function guirefresh
    rm -f ~/.cache/gui-cmds
    __gui_cmds_build
    echo "Desktop app list updated: "(count $__gui_cmds)" apps"
end
