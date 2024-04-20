local this = {};

local utils;
local config;
local screen;
local customization_menu;
local keyframe_handler;

local sdk = sdk;
local tostring = tostring;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local require = require;
local pcall = pcall;
local table = table;
local string = string;
local Vector3f = Vector3f;
local d2d = d2d;
local math = math;
local json = json;
local log = log;
local fs = fs;
local next = next;
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local assert = assert;
local select = select;
local coroutine = coroutine;
local utf8 = utf8;
local re = re;
local imgui = imgui;
local draw = draw;
local Vector2f = Vector2f;
local reframework = reframework;
local os = os;

function this.draw(name, keyframes, step, min, max, format, is_value_percentage)
	if is_value_percentage == nil then
		is_value_percentage = false;
	end

	local keyframes_changed = false;
	local changed = false;

	if imgui.tree_node(name) then
		if imgui.small_button(" + ##0") then
			keyframe_handler.add_keyframe(keyframes, 1);
			keyframes_changed = true;
		end

		imgui.same_line();

		local min_timeline_position = 0;
		local max_timeline_position = 1;
		local keyframe_count = #keyframes;

		for i = 1, keyframe_count do
			if keyframe_count ~= 1 then
				if imgui.small_button(string.format(" - ##%d", i)) then
					keyframe_handler.remove_keyframe(keyframes, i);
					keyframes_changed = true;
					break;
				end

				imgui.same_line();
			end

			if imgui.tree_node(string.format("[%d]", i)) then
				local keyframe = keyframes[i];

				if keyframe == nil then
					break;
				end

				if i > 1 then
					min_timeline_position = keyframes[i - 1].timeline_position;
				end

				if i < keyframe_count then
					max_timeline_position = keyframes[i + 1].timeline_position;
				end

				local timeline_position_percents = 0;
				changed, timeline_position_percents = imgui.drag_float("Timeline Position (%)",
					100 * keyframe.timeline_position, 0.1, 100 * min_timeline_position, 100 * max_timeline_position, "%.1f");
				keyframes_changed = keyframes_changed or changed;

				local timeline_position = timeline_position_percents / 100;

				if changed and timeline_position >= min_timeline_position and timeline_position <= max_timeline_position then
					keyframe.timeline_position = timeline_position
				end

				if keyframes.type == "bool" then
					changed, keyframe.value = imgui.checkbox("Value", keyframe.value);
					keyframes_changed = keyframes_changed or changed;

				elseif keyframes.type == "float" then
					if is_value_percentage then
						local value_percents = 0;

						changed, value_percents = imgui.drag_float("Value (%)", 100 * keyframe.value, 0.1, 0, 100, "%.1f");
						keyframes_changed = keyframes_changed or changed;

						if changed then
							keyframe.value = value_percents / 100;
						end

					else
						changed, keyframe.value = imgui.drag_float("Value", keyframe.value, step, min, max, format);
						keyframes_changed = keyframes_changed or changed;
					end


				else
					changed, keyframe.value = imgui.color_picker_argb("", keyframe.value, customization_menu.color_picker_flags);
					keyframes_changed = keyframes_changed or changed;
				end

				imgui.tree_pop();
			end

			if imgui.small_button(string.format(" + ##%d", i)) then
				keyframe_handler.add_keyframe(keyframes, i + 1);
				keyframes_changed = true;
				break;
			end

			if i ~= keyframe_count then
				imgui.same_line();
			end
		end

		imgui.tree_pop();
	end

	return keyframes_changed;
end

function this.init_module()
	utils = require("Damage_Numbers.utils");
	config = require("Damage_Numbers.config");
	screen = require("Damage_Numbers.screen");
	customization_menu = require("Damage_Numbers.customization_menu");
	keyframe_handler = require("Damage_Numbers.keyframe_handler");
end

return this;