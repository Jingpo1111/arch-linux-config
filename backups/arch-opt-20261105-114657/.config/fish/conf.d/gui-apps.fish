status is-interactive; or return

# Apps that open on a NEW empty desktop and keep running after the terminal closes
set -g GUI_APPS code firefox mysql-workbench dbeaver thunar nautilus vlc obs gimp telegram-desktop libreoffice evince postman discord spotify obsidian

function __new_desktop
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null 2>&1
end

for app in $GUI_APPS
    if type -q $app
        function $app --inherit-variable app
            set -l extra
            switch $app
                case code firefox nautilus
                    set extra --new-window
            end
            __new_desktop
            setsid -f $app $extra $argv >/dev/null 2>&1
        end
    end
end

function telegram
    set -l cmd
    if command -q telegram-desktop
        set cmd telegram-desktop
    else if flatpak info org.telegram.desktop >/dev/null 2>&1
        set cmd "flatpak run org.telegram.desktop"
    else
        set cmd (find ~ /opt -maxdepth 4 -name Telegram -type f -perm -u+x 2>/dev/null | head -1)
    end
    if test -z "$cmd"
        set_color red; echo "Telegram not found"; set_color normal
        return 1
    end
    __new_desktop
    hyprctl dispatch "hl.dsp.exec_cmd(\"$cmd\")" >/dev/null
end

# code with no folder = open the folder I am in
function code
    set -l args $argv
    test (count $args) -eq 0; and set args .
    __new_desktop
    setsid -f code --new-window $args >/dev/null 2>&1
end

# office = open OnlyOffice
function office
    __new_desktop
    setsid -f onlyoffice-desktopeditors $argv >/dev/null 2>&1
end

# Better: go to the first desktop number that has no windows
function __new_desktop
    set -l used (hyprctl workspaces -j | jq ".[] | select(.windows > 0) | .id")
    set -l n 1
    while contains -- $n $used
        set n (math $n + 1)
    end
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$n\" })" >/dev/null 2>&1
end

# MySQL Workbench: start server, stop when closed
function mysql-workbench
    __new_desktop
    setsid -f ~/.local/bin/workbench-run $argv >/dev/null 2>&1
end

# mysql (terminal): start server, stop when you exit
function mysql
    systemctl start mysqld
    command mysql $argv
    pgrep -f mysql-workbench >/dev/null; or systemctl stop mysqld
end

function mysql-workbench
    __new_desktop
    setsid -f ~/.local/bin/workbench-run $argv >/dev/null 2>&1
end

# code: run in a group so closing VS Code also closes its Java/apps
function code
    set -l args $argv
    test (count $args) -eq 0; and set args .
    __new_desktop
    setsid -f ~/.local/bin/code-run --new-window $args >/dev/null 2>&1
end

# code: closing VS Code also closes everything it started
function code
    set -l args $argv
    test (count $args) -eq 0; and set args .
    __new_desktop
    setsid -f ~/.local/bin/code-run --new-window $args >/dev/null 2>&1
end

# code: closing VS Code also closes everything it started
function code
    set -l args $argv
    test (count $args) -eq 0; and set args .
    __new_desktop
    setsid -f ~/.local/bin/code-run --new-window $args >/dev/null 2>&1
end

# postman: open with Wayland + no-GPU options, keep running after terminal closes
function postman
    __new_desktop
    setsid -f postman --ozone-platform-hint=auto --disable-gpu $argv >/dev/null 2>&1
end

# postman: Flatpak version
function postman
    __new_desktop
    setsid -f flatpak run com.getpostman.Postman $argv >/dev/null 2>&1
end

# jflex: no file = open the JFlex window (detached), with a file = normal
function jflex
    if test (count $argv) -eq 0
        setsid -f /usr/bin/jflex >/dev/null 2>&1
    else
        command jflex $argv
    end
end

function jFlex
    jflex $argv
end

# run: open ANY app on a new desktop, keep it running after terminal closes
function run
    __new_desktop
    setsid -f $argv >/dev/null 2>&1
end

# jflex: no file = open window on a new desktop
function jflex
    if test (count $argv) -eq 0
        __new_desktop
        setsid -f /usr/bin/jflex >/dev/null 2>&1
    else
        command jflex $argv
    end
end

# addapp NAME: add an app to the new-desktop list
function addapp
    for a in $argv
        sed -i "s/^set -g GUI_APPS \(.*\)\$/set -g GUI_APPS \1 $a/" ~/.config/fish/conf.d/gui-apps.fish
    end
    exec fish
end

function run
    __new_desktop
    setsid -f $argv >/dev/null 2>&1
end

# run: new desktop + NEW window even if the app is already open
function run
    set -l app $argv[1]
    set -l rest
    test (count $argv) -gt 1; and set rest $argv[2..-1]
    set -l extra
    switch (path basename $app)
        case firefox chromium google-chrome-stable brave code nautilus gedit gnome-text-editor
            set extra --new-window
        case libreoffice
            set extra --nologo
    end
    __new_desktop
    setsid -f $app $extra $rest >/dev/null 2>&1
end

# cleanmem: quit leftovers and tray apps with no open window
function cleanmem
    pkill satty; pkill slurp
    if not pgrep -f "/usr/share/code/code" >/dev/null
        pkill -f app-server-daemon; and echo "Closed codex helper"
    end
    for app in telegram-desktop Telegram discord Discord spotify steam
        if pgrep -x $app >/dev/null
            and not hyprctl clients | grep -qi "class: .*$app"
            pkill -x $app; and echo "Closed $app"
        end
    end
    free -h | head -2
end

# New desktop ONLY if the current one has windows; if it is empty, stay here
function __new_desktop
    set -l here (hyprctl activeworkspace -j | jq ".windows")
    test "$here" = 0; and return
    set -l used (hyprctl workspaces -j | jq ".[] | select(.windows > 0) | .id")
    set -l n 1
    while contains -- $n $used
        set n (math $n + 1)
    end
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$n\" })" >/dev/null 2>&1
end

# New desktop for apps: never desktop 1 (reserved for terminals)
function __new_desktop
    set -l here (hyprctl activeworkspace -j | jq ".id")
    set -l count (hyprctl activeworkspace -j | jq ".windows")
    if test "$here" != 1; and test "$count" = 0
        return
    end
    set -l used (hyprctl workspaces -j | jq ".[] | select(.windows > 0) | .id")
    set -l n 2
    while contains -- $n $used
        set n (math $n + 1)
    end
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$n\" })" >/dev/null 2>&1
end

# New desktop for apps: never desktop 1 (reserved for terminals)
function __new_desktop
    set -l here (hyprctl activeworkspace -j | jq ".id")
    set -l count (hyprctl activeworkspace -j | jq ".windows")
    if test "$here" != 1; and test "$count" = 0
        return
    end
    set -l used (hyprctl workspaces -j | jq ".[] | select(.windows > 0) | .id")
    set -l n 2
    while contains -- $n $used
        set n (math $n + 1)
    end
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$n\" })" >/dev/null 2>&1
end

# NVIDIA GPU on/off (needs a restart)
function gpu-off
    sudo envycontrol -s integrated; and echo "NVIDIA OFF after restart. Run: reboot"
end
function gpu-on
    sudo envycontrol -s hybrid; and echo "NVIDIA ON after restart. Run: reboot"
end
function gpu-status
    echo "Mode: "(envycontrol --query)
    echo "Desktop GPU: "(glxinfo -B 2>/dev/null | grep "OpenGL renderer" | string replace "OpenGL renderer string: " "")
end

