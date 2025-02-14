function fzf_cd
    if set --local selection (bfs -type d | fzf)
        cd $selection
    end
end
