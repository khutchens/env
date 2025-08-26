function fzf_edit
    if set --local selection (bfs -type f (cat .bfsopts 2>/dev/null | tr ' ' '\n') | fzf -m)
        $EDITOR $selection
    end
end
