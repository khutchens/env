function fzf_history
    if set --local selection (history | fzf)
        commandline $selection
    end
end
