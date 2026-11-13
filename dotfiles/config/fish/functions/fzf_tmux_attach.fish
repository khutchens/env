function fzf_tmux_attach
    if set --local session (tmux list-sessions | fzf)
        tmux attach -t (echo $session | grep -o '^[^:]\+')
    end
end
