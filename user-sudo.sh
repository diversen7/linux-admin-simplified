#!/bin/sh
set -eu

if [ "$#" -ne 0 ]; then
    echo "Usage: $0" >&2
    exit 2
fi

if [ "$(id -u)" != 0 ]; then
    echo "Run this report as root to inspect sudo privileges for all users." >&2
    exit 1
fi
command -v sudo >/dev/null || { echo "sudo is required for this report." >&2; exit 1; }
accounts=$(getent passwd)
report_status=0
while IFS=: read -r username fields; do
    [ -n "$username" ] || continue
    lookup_status=0
    report=$(LC_ALL=C sudo -n -l -U "$username" </dev/null 2>&1) || lookup_status=$?
    case "$report" in
        *'
'*) ;; # Preserve diagnostics accompanying a denial.
        "User $username is not allowed to run sudo on "*.) continue ;;
    esac
    if [ "$lookup_status" -eq 0 ]; then
        printf '\n[%s]\n%s\n' "$username" "$report"
    else
        printf 'sudo lookup failed for %s (exit %s): %s\n' "$username" "$lookup_status" "$report" >&2
        report_status=1
    fi
done <<EOF
$accounts
EOF
exit "$report_status"
