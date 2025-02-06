# List parent directories up to root for use with 'fdu' alias
function ls_parents
    while true
        echo $PWD

        if test "$PWD" = "/"
            break
        else
            cd ..
        end
    end
end
