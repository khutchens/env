function check_env_status
    echo Checking .env/ status...
    git -C .env fetch
    git -C .env status --untracked-files=no --short
end
