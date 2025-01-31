if status is-interactive
    alias ls='eza --git --git-repos --classify --group-directories-first --smart-group --header'
    abbr --add ll 'ls -l'
    abbr --add la 'ls -a'
    abbr --add lt 'ls -TL2'
    abbr --add llt 'ls -lTL2'
    abbr --add lltt 'ls -lT'

    abbr --add fd 'cd $(bfs -type d | fzf)'
    abbr --add fdu 'cd $(ls_parents | fzf)'
    abbr --add fe 'hx $(bfs -type f | fzf -m)'

    set fish_color_user magenta
    set fish_color_cwd blue
    
    function fish_prompt
        set -l last_status $status

        set -l host (set_color $fish_color_host)"$hostname"(set_color normal)
        set -l path  $(set_color $fish_color_cwd; short_path $PWD; set_color normal)
        
        set -l stat
        if test $last_status -ne 0
            set stat (set_color red)"[$last_status]"(set_color normal)
        end

        echo "$host $path$stat"
        echo ">"
    end

    function postexec_test --on-event fish_postexec
       echo
    end
end

function short_path
    set --local home_path (string escape --style=regex -- ~)

    for path in $argv
        set path (string replace -r '^'"$home_path"'($|/)' '~$1' $path)
        set dirs $(string split '/' $path)
        if test $(count $dirs) -gt 2
            set dirs $dirs[1] "…" $dirs[-1]
        end
        echo $(string join "/" $dirs)
    end
end

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
