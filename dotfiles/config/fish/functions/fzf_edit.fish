function fzf_edit
    # set --local bfsopts ''

    # for f in '.bfsopts' '~/.local/.bfsopts' '~/.config/.bfsopts'
    #     if test -f $f
    #         set --local bfsopts "(cat .bfsopts 2>/dev/null | tr ' ' '\n')"
    #         break
    #     end
    # end

    if set --local selection (bfs -type f (cat .bfsopts 2>/dev/null | tr ' ' '\n') | fzf -m)
        $EDITOR $selection
    end
end
