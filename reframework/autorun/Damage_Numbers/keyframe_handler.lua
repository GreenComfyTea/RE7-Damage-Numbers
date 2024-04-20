local this = {};

local drawing;

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

this.keyframe_types = {
	bool = "bool",
	float = "float",
	color = "color"
}

function this.calculate_current_value(progress, keyframes)
	local keyframe_count = #keyframes;

	local current_keyframe = keyframes[keyframes.current_keyframe_index];

	if keyframes.current_keyframe_index >= keyframe_count or progress < current_keyframe.timeline_position then
		return current_keyframe.value;
	end

	local next_keyframe = keyframes[keyframes.current_keyframe_index + 1];

	if progress > next_keyframe.timeline_position then
		keyframes.current_keyframe_index = keyframes.current_keyframe_index + 1;
		current_keyframe = next_keyframe;

		if keyframes.current_keyframe_index >= keyframe_count then
			return current_keyframe.value;
		end
	end
	
	local next_keyframe = keyframes[keyframes.current_keyframe_index + 1];

	return this.interpolate_linear(progress, current_keyframe, next_keyframe, keyframes.type);
end


function this.interpolate_linear(progress, current_keyframe, next_keyframe, type)
	if next_keyframe == nil or type == this.keyframe_types.bool then
		return current_keyframe.value;
	end

	local timeline_position_difference = next_keyframe.timeline_position - current_keyframe.timeline_position;
	local timeline_local_progress = (progress - current_keyframe.timeline_position);
	local interpolated_value = 0;

	if type == this.keyframe_types.float then
		interpolated_value = current_keyframe.value + timeline_local_progress * ((next_keyframe.value - current_keyframe.value) / timeline_position_difference);

	else
		local current_alpha, current_red, current_green, current_blue = drawing.color_to_argb(current_keyframe.value);
		local next_alpha, next_red, next_green, next_blue = drawing.color_to_argb(next_keyframe.value);

		local interpolated_alpha = current_alpha + timeline_local_progress * ((next_alpha - current_alpha) / timeline_position_difference);
		local interpolated_red = current_red + timeline_local_progress * ((next_red - current_red) / timeline_position_difference);
		local interpolated_green = current_green + timeline_local_progress * ((next_green - current_green) / timeline_position_difference);
		local interpolated_blue = current_blue + timeline_local_progress * ((next_blue - current_blue) / timeline_position_difference);

		interpolated_value = drawing.argb_to_color(interpolated_alpha, interpolated_red, interpolated_green, interpolated_blue);
	end

	return interpolated_value;
end

function this.add_keyframe(keyframes, position, type)
	local keyframe_count = #keyframes;

	if position < 1 then
		position = 1;
	end

	if position > keyframe_count then
		position = keyframe_count + 1;
	end

	if position == 1 then
		local next_keyframe = keyframes[1];

		local new_keyframe = {};
		new_keyframe.timeline_position = next_keyframe.timeline_position / 2;
		new_keyframe.value = next_keyframe.value;
	
		table.insert(keyframes, position, new_keyframe);

		return;
	end

	if position == keyframe_count + 1 then
		local current_keyframe = keyframes[keyframe_count];

		local new_keyframe = {};
		new_keyframe.timeline_position = (1 + current_keyframe.timeline_position) / 2;
		new_keyframe.value = current_keyframe.value;
	
		table.insert(keyframes, new_keyframe);

		return;
	end

	local current_keyframe = keyframes[position - 1];
	local next_keyframe = keyframes[position];

	local new_keyframe = {};
	new_keyframe.timeline_position = (current_keyframe.timeline_position + next_keyframe.timeline_position) / 2;
	new_keyframe.value = (current_keyframe.value + next_keyframe.value) / 2;

	table.insert(keyframes, position, new_keyframe);
end

function this.remove_keyframe(keyframes, position)
	local keyframe_count = #keyframes;

	if keyframe_count == 0 then
		return;
	end

	if position < 1 then
		position = 1;
	end

	if position > keyframe_count then
		position = keyframe_count;
	end

	table.remove(keyframes, position);
end

function this.init_module()
	drawing = require("Damage_Numbers.drawing");
end

return this;