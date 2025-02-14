function fzf_edit
    if set --local selection (bfs -type f | fzf -m)
        $EDITOR $selection
    end
end
