## Installation

Run the install script and choose between a user level or a system wide install:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/janjbnck/SFLinux/main/install.sh)"
```

To skip the prompt, pass the scope directly:

```bash
curl -fsSL https://raw.githubusercontent.com/janjbnck/SFLinux/main/install.sh | bash -s -- --user
```

```bash
curl -fsSL https://raw.githubusercontent.com/janjbnck/SFLinux/main/install.sh | bash -s -- --system
```

| Scope  | Location                          |
| ------ | --------------------------------- |
| User   | `~/.local/share/fonts/SFLinux`    |
| System | `/usr/local/share/fonts/SFLinux`  |

When run from a local clone, `./install.sh` uses the fonts in the repository instead of downloading them.

## Uninstallation

The uninstall script finds every SFLinux installation (user and system wide) and removes it:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/janjbnck/SFLinux/main/uninstall.sh)"
```
