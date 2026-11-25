#!/bin/sh
set -eu

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: $0 USERNAME" >&2
    exit 2
fi

username=$1
printf 'Brugerkonto: %s\n' "$username"
printf '%s\n' '1) Slet kontoen, og behold hjemmemappen.' \
    '2) Slet både kontoen, hjemmemappen og brugerens lokale postkasse.'
printf 'Vælg 1 eller 2, eller tryk Enter for at annullere: '
IFS= read -r choice || exit 1

case $choice in
    1) exec userdel -- "$username" ;;
    2) exec userdel -r -- "$username" ;;
    '') echo 'Annulleret.' ;;
    *) echo 'Ugyldigt valg. Annulleret.' >&2; exit 2 ;;
esac
