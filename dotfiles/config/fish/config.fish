if status is-interactive
    # Commands to run in interactive sessions can go here

    alias ls='eza --git --git-repos --classify --group-directories-first --smart-group --header'
    abbr --add ll 'ls -l'
    abbr --add la 'ls -a'
    abbr --add lt 'ls -TL2'
    abbr --add llt 'ls -lTL2'
    abbr --add lltt 'ls -lT'

    abbr --add fd 'cd $(bfs -type d | fzf)'
    abbr --add fdu 'cd $(ls_parents | fzf)'
    abbr --add fe 'hx $(bfs -type f | fzf -m)'
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
