local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

if wezterm.config_builder() then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Macchiato'
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.window_decorations = 'RESIZE'
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12
config.default_cursor_style = 'SteadyUnderline'
config.scrollback_lines = 10420

config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.colors = {
  split = '#363a4f', 
}

wezterm.on('update-right-status', function(window, pane)

  local name = window:active_key_table()
  if name then
    name = ' MODE: ' .. name:upper() .. ' '
  else
    name = ' MODE: INSERT ' -- Default base state
  end

  window:set_right_status(wezterm.format({
    { Background = { Color = '#8bd5ca' } },
    { Foreground = { Color = '#1e1e2e' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = name },
  }))
end)

config.keys = {
  {
    key = 'Escape',
    mods = 'ALT',
    action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true },
  },
  { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
}

local function apply_shared_bindings(key_table)
  local shared = {
    { key = 'i', action = act.ClearKeyTableStack },
  }
  for _, binding in ipairs(shared) do
    table.insert(key_table, binding)
  end
end

local normal_mode = {
  { key = 'p', action = act.ActivateKeyTable { name = 'pane', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 't', action = act.ActivateKeyTable { name = 'tab', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'r', action = act.ActivateKeyTable { name = 'resize', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'f', action = act.TogglePaneZoomState },
  { key = 'n', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'n', mods = "SHIFT", action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'd', mods = "CTRL", action = act.CloseCurrentPane { confirm = true } },
  { key = 'LeftArrow', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
  { key = 'DownArrow', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow', action = act.ActivatePaneDirection 'Up' },
  { key = 'h', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', action = act.ActivatePaneDirection 'Right' },
  { key = 'j', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', action = act.ActivatePaneDirection 'Up' },
  { key = 'LeftArrow', mods = "CTRL", action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', mods = "CTRL", action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'DownArrow', mods = "CTRL", action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'UpArrow', mods = "CTRL", action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'h', mods = "CTRL", action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'l', mods = "CTRL", action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'j', mods = "CTRL", action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', mods = "CTRL", action = act.AdjustPaneSize { 'Up', 1 } },
}
apply_shared_bindings(normal_mode)

local pane_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'd', mods = "CTRL", action = act.CloseCurrentPane { confirm = true } },
  { key = 'n', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'v', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd', action = act.CloseCurrentPane { confirm = true } },
  { key = 'f', action = act.TogglePaneZoomState },
  { key = 'LeftArrow', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
  { key = 'DownArrow', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow', action = act.ActivatePaneDirection 'Up' },
  { key = 'h', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', action = act.ActivatePaneDirection 'Right' },
  { key = 'j', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', action = act.ActivatePaneDirection 'Up' },
}
apply_shared_bindings(pane_mode)

local tab_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'd', mods = "CTRL", action = act.CloseCurrentPane { confirm = true } },
  { key = 'n', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'h', action = act.ActivateTabRelative(-1) },
  { key = 'l', action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow', action = act.ActivateTabRelative(1) },
  { key = 'RightArrow', action = act.ActivateTabRelative(1) },
  { key = 'd', action = act.CloseCurrentTab { confirm = true } },
}
apply_shared_bindings(tab_mode)

local resize_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'd', mods = "CTRL", action = act.CloseCurrentPane { confirm = true } },
  { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
}
apply_shared_bindings(resize_mode)

-- Assigning our custom modes to WezTerm's engine
config.key_tables = {
  normal = normal_mode,
  pane = pane_mode,
  tab = tab_mode,
  resize = resize_mode,
}

return config
