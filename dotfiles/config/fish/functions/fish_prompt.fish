# Prompt
function fish_prompt
    set --local last_status $status

    echo -s (
        if set --query SSH_TTY
            set_color $fish_color_host
            echo -n "$hostname "
        end

        set_color $fish_color_cwd
        short_path $PWD

        if test $last_status -eq 0
            set_color blue
        else
            set_color red
        end

        echo -n " >"
    )
end
