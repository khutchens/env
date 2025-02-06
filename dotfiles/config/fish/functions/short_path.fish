# Shorten a path by keeping first and last elements and replacing everything in between with "…"
function short_path
    set --local home_path (string escape --style=regex -- ~)

    for path in $argv
        set path (string replace --regex '^'"$home_path"'($|/)' '~$1' $path)
        set dirs $(string split '/' $path)
        if test $(count $dirs) -gt 2
            set dirs $dirs[1] "…" $dirs[-1]
        end
        echo $(string join "/" $dirs)
    end
end
