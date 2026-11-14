function jj_workspace -a parent_path repository_dir
    set --local workspaces (          \
        jj workspace list             \
            --repository $parent_path/$repository_dir  \
            --template 'root ++ "\n"' \
    )
    or return

    set --local orphan_workspaces
    for dir in $parent_path/*
        if test $dir = $repository_dir
            echo "$dir: base repo"
        else if not test -d $dir
            echo (set_color grey)"$dir (not a directory)"(set_color normal)
        else if not test -d $dir/.jj
            echo (set_color grey)"$dir (not a jj workspace)"(set_color normal)
        else if contains -- $dir $workspaces
            echo "$dir"
        else
            echo (set_color yellow)"$dir (dead)"(set_color normal)
            set --append orphan_workspaces $dir
        end
    end
end
