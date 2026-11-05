status is-interactive; or return

# Modern prompt
starship init fish | source

# ls / ll with icons, cat with colours
function ls; eza --icons --group-directories-first $argv; end
function ll; eza -la --icons --git --group-directories-first $argv; end
function tree; eza --tree --icons $argv; end
function cat; bat --style=plain --paging=never $argv; end
