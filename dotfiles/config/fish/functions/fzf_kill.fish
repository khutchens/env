function fzf_kill
    set --local platform (uname)

    if test $platform = 'Linux'
        set --function ps_cmd ps --user=kyle --format=pid,tty,command --no-headers
    else if test $platform = 'Darwin'
        set --function ps_cmd ps -U $USER -o pid=,tty=,command= | grep -v '??'
    else
        echo "Unsupported platform: $platform"
        return
    end

    set --local selection ($ps_cmd | fzf -m | awk '{print $1}')

    if test $pipestatus[2] -eq 0
        kill -9 $selection
    end
end
