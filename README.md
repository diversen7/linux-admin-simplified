# Linux user overview

Run these commands from the project directory. They only read account and session information and can be run as an ordinary user.

| Command | What it shows |
| --- | --- |
| `./list-users` | Username, UID, home directory and shell for accounts within the regular user range defined by `UID_MIN` and `UID_MAX` in `/etc/login.defs`. |
| `./list-users --all` | The same columns for every account listed by `getent passwd`, including root and service accounts. |
| `./logged-in-users` | One row per login session reported by `who`. A user with multiple sessions can appear more than once. |

## Standard Linux commands

List account names, one per line, including system accounts:

```sh
getent passwd | cut -d: -f1
```

The colon separates fields. The first field (`-f1`) contains the username.

Show current login sessions:

```sh
who
```

Show login sessions with idle time and current activity:

```sh
w
```
