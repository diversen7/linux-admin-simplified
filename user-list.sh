#!/bin/sh
set -eu

usage() {
    echo "Usage: $0 [--all | --sudo]" >&2
    exit 2
}

[ "$#" -le 1 ] || usage
case "${1-}" in
    '') all=0 ;;
    --all) all=1 ;;
    --sudo)
        if [ "$(id -u)" != 0 ]; then
            echo "Run this report as root to inspect sudo privileges for all users." >&2
            exit 1
        fi
        command -v sudo >/dev/null || { echo "sudo is required for this report." >&2; exit 1; }
        accounts=$(getent passwd)
        while IFS=: read -r username fields; do
            [ -n "$username" ] || continue
            printf '\n[%s]\n' "$username"
            # A denied account returns a nonzero status. Keep reporting other accounts.
            sudo -n -l -U "$username" </dev/null || continue
        done <<EOF
$accounts
EOF
        exit 0
        ;;
    *) usage ;;
esac

accounts=$(getent passwd)
printf '%s\n' "$accounts" | awk -F: -v all="$all" '
    BEGIN {
        if (!all) {
            while ((getline line < "/etc/login.defs") > 0) {
                count = split(line, field, " ")
                if (count < 2 || field[2] !~ /^[0-9]+$/) continue
                if (field[1] == "UID_MIN") min_uid = field[2] + 0
                if (field[1] == "UID_MAX") max_uid = field[2] + 0
            }
            close("/etc/login.defs")
            if (max_uid <= 0 || min_uid == "" || min_uid > max_uid) {
                print "Cannot read the UID range in /etc/login.defs. Try --all." > "/dev/stderr"
                exit 1
            }
        }
        printf "%-20s %-8s %-24s %s\n", "USER", "UID", "HOME", "SHELL"
    }
    NF >= 7 && (all || ($3 + 0 >= min_uid && $3 + 0 <= max_uid)) {
        printf "%-20s %-8s %-24s %s\n", $1, $3, $6, $7
    }
'
