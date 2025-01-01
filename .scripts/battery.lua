local lgi = require("lgi")
local UPowerGlib = lgi.UPowerGlib

local function get_battery()
	for _, device in pairs(UPowerGlib.Client():get_devices()) do
		if device:get_object_path():match("/battery_BAT[0-9]+$") then
			return device
		end
	end

	error("No battery found! Are you on a desktop PC or server?")
end

function draw(cr)
    local battery = get_battery()
    local percentage = 100 * (battery["energy"] / battery["energy-full"])
    local start = 0
    local width = 64
    local state = battery["state"] 

    local color = {166/255, 218/255, 149/255}

    if state == 2 then
      if percentage <= 80 then
        color = {202/255, 211/255, 245/255}
      end
      if percentage <= 50 then
        color = {238/255, 212/255, 159/255}
      end
      if percentage <= 30 then
        color = {245/255, 169/255, 127/255}
      end
      if percentage <= 20 then
        color = {230/255, 69/255, 83/255}
      end

    end

    if percentage <= 95 then
      cr:set_source_rgb(unpack(color))
      cr:move_to(96 - 30, 16)
      cr:set_font_size(12)
      cr:show_text(("%3.00f%%"):format(percentage))
      cr:stroke()
    else
      start = 10
      width = 80
    end

    local charge_width = width * percentage / 100

    cr:set_source_rgb(128/255, 135/255, 162/255)
    cr:move_to(charge_width, 12)
    cr:set_line_width(4)
    cr:rel_line_to(width - charge_width - 1, 0)
    cr:stroke()

    cr:move_to(width - 1, 12)
    cr:set_line_width(2)
    cr:rel_line_to(1, 0)
    cr:stroke()

    cr:set_source_rgb(unpack(color))
    cr:move_to(start + 1, 12)
    cr:set_line_width(4)
    cr:rel_line_to(charge_width - 1, 0)
    cr:stroke()

    cr:move_to(start, 12)
    cr:set_line_width(2)
    cr:rel_line_to(charge_width, 0)
    cr:stroke()
    

    return 0
end
