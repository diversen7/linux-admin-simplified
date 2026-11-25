#!/bin/sh
set -eu

: "${HOME:?Set HOME to the target user's home directory}"
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
bin_dir=$HOME/bin
mkdir -p -- "$bin_dir"
for script in "$project_dir"/*.sh; do
    install -m 755 -- "$script" "$bin_dir/"
done

profile=$HOME/.profile
login_shell=${SHELL:-/bin/sh}
case ${login_shell##*/} in
    bash)
        for name in .bash_profile .bash_login; do
            if [ -f "$HOME/$name" ]; then
                profile=$HOME/$name
                break
            fi
        done
        ;;
    zsh) profile=${ZDOTDIR:-$HOME}/.zprofile ;;
esac

marker='# linux-admin-simplified: user commands'
if ! grep -qxF "$marker" "$profile" 2>/dev/null; then
    printf '\n%s\n' "$marker" >> "$profile"
    cat >> "$profile" <<'PROFILE'
case ":${PATH-}:" in
    *:"$HOME/bin":*) ;;
    *) export PATH="$HOME/bin${PATH:+:$PATH}" ;;
esac
PROFILE
fi

printf 'Installed commands in %s. Log in again to load %s.\n' "$bin_dir" "$profile"
