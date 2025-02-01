if status is-interactive
    # No greeting on login
    set --global fish_greeting

    # Aliases
    alias ls='eza --git --git-repos --classify --group-directories-first --smart-group --header'
    abbr --add ll   'ls -l'
    abbr --add la   'ls -a'
    abbr --add lt   'ls -TL2'
    abbr --add llt  'ls -lTL2'
    abbr --add lltt 'ls -lT'

    abbr --add fdu 'cd $(ls_parents | fzf)'
    abbr --add fd  'cd $(bfs -type d | fzf)'
    abbr --add fe  'hx $(bfs -type f | fzf -m)'

    if test (uname) = 'Linux'
        abbr --add ip 'ip --color=auto -brief'
    end
    
    # Colors
    set fish_color_user magenta
    set fish_color_cwd blue
    
    # Prompt
    function fish_prompt
        set --local host
        if set --query SSH_TTY
            set host (set_color $fish_color_host)"$hostname "(set_color normal)
        end

        set --local path  $(set_color $fish_color_cwd; short_path $PWD; set_color normal)

        echo "$host$path>"
    end
end

# Path
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

# Configs
set --global --export EDITOR hx

# Shorten a path by keeping first and last elements and replacing everything in bewtween with "…"
function short_path
    set --local home_path (string escape --style=regex -- ~)

    for path in $argv
        set path (string replace --regex '^'"$home_path"'($|/)' '~$1' $path)
        set dirs $(string split '/' $path)
        if test $(count $dirs) -gt 2
            set dirs $dirs[1] "…" $dirs[-1]
        end
        echo $(string join "/" $dirs)
    end
end

# List parent directories up to root for use with 'fdu' alias
function ls_parents
    while true
        echo $PWD

        if test "$PWD" = "/"
            break
        else
            cd ..
        end
    end
end

set local_config ~/.local/config.fish
if test -e $local_config
    source $local_config
end
