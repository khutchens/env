function check_env_status
    echo "Checking .env/ status..."

    set env_path ~/.env
    git -C $env_path fetch

    set branch_status (git -C $env_path status | grep --only-matching "\(ahead\|behind\)[^,]*")
    set local_status (git -C $env_path status --short)

    if test -n "$branch_status"
        echo (set_color red)"Warning"(set_color normal)": Local .env is $branch_status"
    end

    if test -n "$local_status"
        echo (set_color red)"Warning"(set_color normal)": Local .env is unclean:"
        git -C $env_path status --short
    end
end
