# Packet Hook Library

A custom Roblox UI library built for the **Packet Hook** exploit hub.

## Load

```lua
local repo = 'https://raw.githubusercontent.com/shamodresellz-cell/Packet-Hook-Lib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
```

## Example Script

[Example.lua](Example.lua)

## Addons

[ThemeManager.lua](ThemeManager.lua) — color themes, UI transparency, autoload support

[SaveManager.lua](SaveManager.lua) — config save/load system with autoload support

## Features

- Tabs and group boxes with automatic scrolling
- Toggles, sliders, dropdowns, color pickers, key pickers, text inputs
- Search bar to quickly find any element by name
- Theme system — accent, background, main color, outline, and UI transparency
- Config system — save and load toggle/slider/dropdown states per game
- Autoload for both themes and configs on hub start
- Notification system
- Keybind menu with customizable menu toggle key