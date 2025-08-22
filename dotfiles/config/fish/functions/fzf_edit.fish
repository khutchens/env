function fzf_edit
    set -x
    if set --local selection (bfs -type f (cat .bfsopts | tr ' ' '\n') | fzf -m)
        $EDITOR $selection
    end
end
