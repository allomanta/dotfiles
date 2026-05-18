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
  split = '#363a4f', -- Catppuccin Macchiato Surface0
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
  -- Entering Normal Mode traps unmapped keys using prevent_fallback = true
  {
    key = 'Escape',
    mods = 'ALT',
    action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true },
  },
  {
    key = 'g',
    mods = 'CTRL',
    action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true },
  },
  -- Retaining your custom shortcuts
  { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
}

-- Helper function to inject your Zellij "shared_except locked" shortcuts
local function apply_shared_bindings(key_table)
  local shared = {
    -- Alt + h/j/k/l or Alt + Arrows to navigate between splits instantly
    { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
    { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
    { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
    -- Pressing 'i' instantly locks the terminal back down
    { key = 'i', action = act.ClearKeyTableStack },
  }
  for _, binding in ipairs(shared) do
    table.insert(key_table, binding)
  end
end

local normal_mode = {
  -- Switch into other modes, capturing/blocking passthrough cleanly
  { key = 'p', action = act.ActivateKeyTable { name = 'pane', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 't', action = act.ActivateKeyTable { name = 'tab', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'r', action = act.ActivateKeyTable { name = 'resize', one_shot = false, prevent_fallback = true, replace_current = true } },
  -- Direct navigation mapping
  { key = 'h', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', action = act.ActivatePaneDirection 'Right' },
  { key = 'j', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', action = act.ActivatePaneDirection 'Up' },
}
apply_shared_bindings(normal_mode)

local pane_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'n', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } }, 
  { key = 'v', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },   
  { key = 'd', action = act.CloseCurrentPane { confirm = true } },
  { key = 'f', action = act.TogglePaneZoomState },                              
  -- Direct navigation inside Pane mode mapping
  { key = 'h', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', action = act.ActivatePaneDirection 'Right' },
  { key = 'j', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', action = act.ActivatePaneDirection 'Up' },
}
apply_shared_bindings(pane_mode)

local tab_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'n', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'h', action = act.ActivateTabRelative(-1) },
  { key = 'l', action = act.ActivateTabRelative(1) },
  { key = 'd', action = act.CloseCurrentTab { confirm = true } },
}
apply_shared_bindings(tab_mode)

local resize_mode = {
  { key = 'Escape', action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
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
