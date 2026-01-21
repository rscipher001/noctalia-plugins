# Niri Color Picker

A Noctalia bar widget plugin that uses niri's built-in color picker to pick colors from anywhere on the screen and copy the hex value to clipboard.

**⚠️ Requires Niri Compositor** - This plugin only works with the [Niri](https://github.com/YaLTeR/niri) compositor.

## Features

- **Left-click** the widget to activate the color picker
- **Right-click** to open the color history panel
- **Color history panel** showing last 36 picked colors in a 6x6 grid (configurable)
- Click any color in the history to copy it to clipboard
- Persists colors across restarts

## Requirements

- **Niri compositor** - This plugin uses `niri msg pick-color` command
- **wl-copy** - Used to copy the color to clipboard (part of `wl-clipboard` package)

**Usage from command line:**
```bash
# Pick a color
qs -c noctalia-shell ipc call plugin:niri-color-picker pickColorCommand

# Open color history panel
qs -c noctalia-shell ipc call plugin:niri-color-picker togglePanel
```
