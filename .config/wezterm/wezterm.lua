local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder() then
  config = wezterm.config_builder()
end

-- Theme
config.color_scheme = 'Catppuccin Macchiato'

-- Tab
config.hide_tab_bar_if_only_one_tab = true

-- Window
config.window_background_opacity = 0.8
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

-- Font
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 11
config.default_cursor_style = 'SteadyUnderline'

-- Shell
config.default_prog = { '/usr/bin/zsh'}

-- History
config.scrollback_lines = 10420

-- Keys
config.keys = {
  {
    key = 'w',
    mods = 'SUPER',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  { 
    key = "UpArrow",
    mods = "SHIFT",
    action = wezterm.action.ScrollToPrompt(-1)
  },
 { 
    key = "DownArrow", 
    mods = "SHIFT", 
    action = wezterm.action.ScrollToPrompt(1) 
  },
}

return config
