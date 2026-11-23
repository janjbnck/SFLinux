## Installation

Run the install script and choose between a user level or a system wide install. It also sets Apple Color Emoji as the default emoji font:

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

## Uninstallation

The uninstall script removes the fonts and the emoji font config from both install locations:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/janjbnck/SFLinux/main/uninstall.sh)"
```
