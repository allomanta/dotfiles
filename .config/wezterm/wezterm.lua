local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

if wezterm.config_builder() then
  config = wezterm.config_builder()
end


config.front_end = 'OpenGL'
config.prefer_egl = true
config.enable_wayland = true
config.wayland_window_background_blur = true

config.window_background_opacity = 0.9
config.color_scheme = 'Catppuccin Macchiato'
-- config.macos_window_background_blur = 20
config.wayland_window_background_blur = true
config.window_decorations = 'RESIZE'
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12
config.default_cursor_style = 'SteadyUnderline'
config.scrollback_lines = 10420

config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.colors = {
  split = '#ca83cb',
}

local resurrect = wezterm.plugin.require(
  'https://github.com/MLFlexer/resurrect.wezterm'
)

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
  { key = 'c',     mods = 'CMD', action = act.CopyTo 'Clipboard' },
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
}

local function prompt_rename_tab()
  return act.PromptInputLine {
    description = 'Enter new name for tab',
    action = wezterm.action_callback(function(window, pane, line)
      -- line is nil if you press Escape
      if line and #line > 0 then
        window:active_tab():set_title(line)
      end
    end),
  }
end

local function apply_shared_bindings(key_table)
  local shared = {
    { key = 'i', action = act.ClearKeyTableStack },
  }
  for _, binding in ipairs(shared) do
    table.insert(key_table, binding)
  end
end

local function activate_pane_or_tab(direction, tab_delta)
  return wezterm.action_callback(function(window, pane)
    local tab = window:active_tab()
    local target_pane = tab:get_pane_direction(direction)

    if target_pane ~= nil then
      window:perform_action(act.ActivatePaneDirection(direction), pane)
    else
      window:perform_action(act.ActivateTabRelative(tab_delta), pane)
    end
  end)
end

local function prompt_save_window_layout()
  return act.PromptInputLine {
    description = 'Name this window layout',
    action = wezterm.action_callback(function(window, pane, line)
      if not line or line == '' then
        return
      end

      resurrect.state_manager.save_state(
        resurrect.window_state.get_window_state(window:mux_window()),
        line
      )

      window:toast_notification(
        'wezterm',
        'Saved window layout: ' .. line,
        nil,
        3000
      )
    end),
  }
end

local function delete_saved_layout()
  return wezterm.action_callback(function(window, pane)
    resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id)
      resurrect.state_manager.delete_state(id)

      window:toast_notification(
        'wezterm',
        'Deleted saved layout',
        nil,
        3000
      )
    end, {
      title = 'Delete Saved Layout',
      description = 'Select layout to delete and press Enter',
      fuzzy_description = 'Search layout to delete: ',
      is_fuzzy = true,

      -- Since you are saving window layouts only:
      ignore_workspaces = true,
      ignore_tabs = true,
      ignore_windows = false,
    })
  end)
end

local function restore_window_layout_in_current_window()
  return wezterm.action_callback(function(window, pane)
    resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, label)
      local type = string.match(id, '^([^/]+)')
      local name = string.match(id, '([^/]+)$')
      name = string.match(name, '(.+)%..+$')

      if type ~= 'window' then
        window:toast_notification(
          'wezterm',
          'Pick a saved window layout',
          nil,
          3000
        )
        return
      end

      local state = resurrect.state_manager.load_state(name, 'window')

      resurrect.window_state.restore_window(pane:window(), state, {
        close_open_tabs = true,
        window = pane:window(),
        relative = true,
        restore_text = true,
        resize_window = false,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
      })
    end, {
      title = 'Load Window Layout',
      description = 'Select a window layout and press Enter',
      fuzzy_description = 'Search window layout: ',
      ignore_workspaces = true,
      ignore_tabs = true,
      ignore_windows = false,
    })
  end)
end

local normal_mode = {
  { key = 's',          mods = 'SHIFT',                                                                                                      action = act.Multiple({ act.ClearKeyTableStack, prompt_save_window_layout() }) },
  { key = 'o',          mods = 'SHIFT',                                                                                                      action = act.Multiple({ act.ClearKeyTableStack, restore_window_layout_in_current_window() }) },
  { key = 'x',          mods = 'SHIFT',                                                                                                      action = act.Multiple({ act.ClearKeyTableStack, delete_saved_layout() }) },
  { key = 'p',          action = act.ActivateKeyTable { name = 'pane', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 't',          action = act.ActivateKeyTable { name = 'tab', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'r',          action = act.ActivateKeyTable { name = 'resize', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'f',          action = act.TogglePaneZoomState },
  { key = 'n',          mods = "SHIFT",                                                                                                      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'n',          action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'd',          mods = "CTRL",                                                                                                       action = act.CloseCurrentPane { confirm = true } },
  { key = 'LeftArrow',  action = activate_pane_or_tab('Left', -1) },
  { key = 'RightArrow', action = activate_pane_or_tab('Right', 1) },
  { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
  { key = 'h',          action = activate_pane_or_tab('Left', -1) },
  { key = 'l',          action = activate_pane_or_tab('Right', 1) },
  { key = 'j',          action = act.ActivatePaneDirection 'Down' },
  { key = 'k',          action = act.ActivatePaneDirection 'Up' },

  { key = 'h',          mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(-1) },
  { key = 'l',          mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(1) },
  { key = 'LeftArrow',  mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(1) },

  { key = 'LeftArrow',  mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'DownArrow',  mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'UpArrow',    mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'h',          mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'l',          mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'j',          mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k',          mods = "CTRL",                                                                                                       action = act.AdjustPaneSize { 'Up', 1 } },
  { key = '1',          action = act.ActivateTab(0) },
  { key = '2',          action = act.ActivateTab(1) },
  { key = '3',          action = act.ActivateTab(2) },
  { key = '4',          action = act.ActivateTab(3) },
  { key = '5',          action = act.ActivateTab(4) },
  { key = '6',          action = act.ActivateTab(5) },
  { key = '7',          action = act.ActivateTab(6) },
  { key = '8',          action = act.ActivateTab(7) },
  { key = '9',          action = act.ActivateTab(8) }, }
apply_shared_bindings(normal_mode)

local pane_mode = {
  { key = 'Escape',     action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'd',          mods = "CTRL",                                                                                                       action = act.CloseCurrentPane { confirm = true } },
  { key = 'n',          action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'v',          action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd',          action = act.CloseCurrentPane { confirm = true } },
  { key = 'f',          action = act.TogglePaneZoomState },
  { key = 'LeftArrow',  action = activate_pane_or_tab('Left', -1) },
  { key = 'RightArrow', action = activate_pane_or_tab('Right', 1) },
  { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
  { key = 'h',          action = activate_pane_or_tab('Left', -1) },
  { key = 'l',          action = activate_pane_or_tab('Right', 1) },
  { key = 'j',          action = act.ActivatePaneDirection 'Down' },
  { key = 'k',          action = act.ActivatePaneDirection 'Up' },

}
apply_shared_bindings(pane_mode)

local tab_mode = {
  { key = 'Escape',     action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'r',          action = act.Multiple({ act.ClearKeyTableStack, prompt_rename_tab() }) },
  { key = 'd',          mods = "CTRL",                                                                                                       action = act.CloseCurrentPane { confirm = true } },
  { key = 'n',          action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'h',          action = act.ActivateTabRelative(-1) },
  { key = 'l',          action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow',  action = act.ActivateTabRelative(-1) },
  { key = 'RightArrow', action = act.ActivateTabRelative(1) },
  { key = 'h',          mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(-1) },
  { key = 'l',          mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(1) },
  { key = 'LeftArrow',  mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'SHIFT',                                                                                                      action = act.MoveTabRelative(1) },
  { key = 'd',          action = act.CloseCurrentTab { confirm = true } },
  { key = '1',          action = act.ActivateTab(0) },
  { key = '2',          action = act.ActivateTab(1) },
  { key = '3',          action = act.ActivateTab(2) },
  { key = '4',          action = act.ActivateTab(3) },
  { key = '5',          action = act.ActivateTab(4) },
  { key = '6',          action = act.ActivateTab(5) },
  { key = '7',          action = act.ActivateTab(6) },
  { key = '8',          action = act.ActivateTab(7) },
  { key = '9',          action = act.ActivateTab(8) },
}
apply_shared_bindings(tab_mode)

local resize_mode = {
  { key = 'Escape',     action = act.ActivateKeyTable { name = 'normal', one_shot = false, prevent_fallback = true, replace_current = true } },
  { key = 'd',          mods = "CTRL",                                                                                                       action = act.CloseCurrentPane { confirm = true } },
  { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },
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
