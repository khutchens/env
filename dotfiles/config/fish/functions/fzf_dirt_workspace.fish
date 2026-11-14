function fzf_dirt_workspace -a repository
    set --local jj_opts          \
        --repository $repository \
        --color always                

    if set --local workspace (jj workspace list $jj_opts | fzf --ansi)
        cd (echo $workspace | awk '{print $2}')
    end
end
