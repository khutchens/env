if status is-interactive
    if test $SHLVL -eq 1
        check_env_status
    end
    
    # No greeting on login
    set --global fish_greeting

    # Aliases
    if type -q eza
        alias ls='eza --classify --group-directories-first --smart-group --header'
    end
    abbr --add ll   'ls -l'
    abbr --add la   'ls -a'
    abbr --add lt   'ls -TL2'
    abbr --add ltt  'ls -T'

    abbr --add fdu fzf_cd_up
    abbr --add fd  fzf_cd
    abbr --add fe  fzf_edit
    abbr --add fh  fzf_history
    abbr --add fk  fzf_kill
    abbr --add fs  "screen (find /dev/serial -type l | fzf) 115200"

    if test (uname) = 'Linux'
        abbr --add ip 'ip --color=auto -brief'
    end
    
    # Colors
    set fish_color_user    magenta
    set fish_color_host    yellow
    set fish_color_cwd     magenta
    set fish_color_command white --bold

    # Completions
    if type -q jj
        COMPLETE=fish jj | source
    end
end

# Path
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

# Configs
if type -q hx
    set --global --export EDITOR hx
else
    set --global --export EDITOR vim
end

set local_config ~/.local/config.fish
if test -e $local_config
    source $local_config
end
