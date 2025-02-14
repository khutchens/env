function fzf_cd_up
    if set --local selection (ls_parents | fzf)
        cd $selection
    end
end
