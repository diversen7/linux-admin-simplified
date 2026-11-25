#!/bin/sh
set -eu

case "${1-}" in
    '') all=0 ;;
    --all) all=1 ;;
    *) echo "Usage: $0 [--all]" >&2; exit 2 ;;
esac
if [ "$#" -gt 1 ]; then
    echo "Usage: $0 [--all]" >&2
    exit 2
fi

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
