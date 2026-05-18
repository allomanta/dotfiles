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
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.window_decorations = 'RESIZE'

-- Font
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12
config.default_cursor_style = 'SteadyUnderline'

-- History
config.scrollback_lines = 10420



-- Keys
config.keys = {
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
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
local all_characters = [[`1234567890-=qwertyuiop[]\asdfghjklJK;'zxbm,./]]

return config
