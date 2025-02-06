if status is-interactive
    echo Checking .env/ status...
    git -C .env fetch
    git -C .env status --untracked-files=no --short
    
    # No greeting on login
    set --global fish_greeting

    # Aliases
    if type -q eza
        alias ls='eza --classify --group-directories-first --smart-group --header'
    end
    abbr --add ll   'ls -l'
    abbr --add la   'ls -a'
    abbr --add lt   'ls -TL2'
    abbr --add ltt  'ls -T'

    abbr --add fdu 'cd $(ls_parents | fzf)'
    abbr --add fd  'cd $(bfs -type d | fzf)'
    abbr --add fe  'hx $(bfs -type f | fzf -m)'
    abbr --add fh  'commandline (history | fzf)'

    if test (uname) = 'Linux'
        abbr --add ip 'ip --color=auto -brief'
    end
    
    # Colors
    set fish_color_user    magenta
    set fish_color_host    yellow
    set fish_color_cwd     magenta
    set fish_color_command white --bold
    
    # Prompt
    function fish_prompt
        set --local last_status $status

        echo -s (
            if set --query SSH_TTY
                set_color $fish_color_host
                echo -n "$hostname "
            end

            set_color $fish_color_cwd
            short_path $PWD

            if test $last_status -eq 0
                set_color blue
            else
                set_color red
            end

            echo -n " >"
        )
    end
end

# Path
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

# Configs
if type -q hx
    set --global --export EDITOR hx
else
    set --global --export EDITOR vim
end

# Shorten a path by keeping first and last elements and replacing everything in between with "…"
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
