require("zoxide"):setup {
    update_db = true,
}
require("git"):setup()

-- ~/.config/yazi/init.lua
THEME.git = THEME.git or {}
THEME.git.modified_sign = "M"
THEME.git.deleted_sign = "D"

Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)
