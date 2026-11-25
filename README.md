# Linux user administration

Run these commands from the project directory, or omit `./` after installing them. The commands in the table only read account and session information and can be run as an ordinary user.

| Command | What it shows |
| --- | --- |
| `./user-list.sh` | Username, UID, home directory and shell for accounts within the regular user range defined by `UID_MIN` and `UID_MAX` in `/etc/login.defs`. |
| `./user-list.sh --all` | The same columns for every account listed by `getent passwd`, including root and service accounts. |
| `./user-logged-in.sh` | One row per login session reported by `who`. A user with multiple sessions can appear more than once. |

## Delete a local user

Run `sudo ./user-delete.sh USERNAME` from the project directory, replacing `USERNAME` with the account name. If you are already root, omit `sudo`. Check the displayed username before choosing an option.

1. Delete the account and keep its home directory (`userdel`).
2. Delete the account, its home directory and its local mail spool (`userdel -r`).

Press Enter at the menu to cancel. Selecting 1 or 2 runs the chosen command immediately.

## Install or update for your user

With Git installed, run the same command for the first installation and for updates:

```sh
(repo="$HOME/linux-admin-simplified"; if [ -e "$repo/.git" ]; then git -C "$repo" pull --ff-only; else git clone https://github.com/diversen7/linux-admin-simplified.git "$repo"; fi && "$repo/setup/install.sh")
```

The first run clones the project into `~/linux-admin-simplified`. Later runs update that checkout from its configured upstream. The installer runs only after Git succeeds.

Run the installer as the user who will use the commands. It creates `~/bin` if needed and copies every top-level `.sh` command there with executable permissions. Run it again to update the installed copies. Files in `~/bin` with matching names are replaced.

The installer adds a PATH entry to `~/.profile`. For Bash it uses an existing `~/.bash_profile` or `~/.bash_login` first, in that order. For Zsh it uses `.zprofile` in `$ZDOTDIR` or your home directory. The entry checks whether `~/bin` is already on PATH.

Log in again, or run the following in your current Bash, Zsh or POSIX shell to use the commands immediately:

```sh
export PATH="$HOME/bin:$PATH"
user-list.sh
```

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
