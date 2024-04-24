local this = {};

local utils;
local config;
local screen;
local keyframe_customization;
local time;
local error_handler;

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

this.font = nil;
this.font_range = {0x1, 0xFFFF, 0};
this.is_opened = false;

this.window_flags = 0x10120;
this.color_picker_flags = 327680;
this.decimal_input_flags = 33;

this.config_changed = false;

this.fonts = {	"Arial", "Arial Black", "Bahnschrift", "Calibri", "Cambria", "Cambria Math", "Candara",
				"Comic Sans MS", "Consolas", "Constantia", "Corbel", "Courier New", "Ebrima",
				"Franklin Gothic Medium", "Gabriola", "Gadugi", "Georgia", "HoloLens MDL2 Assets", "Impact",
				"Ink Free", "Javanese Text", "Leelawadee UI", "Lucida Console", "Lucida Sans Unicode",
				"Malgun Gothic", "Marlett", "Microsoft Himalaya", "Microsoft JhengHei", "Microsoft New Tai Lue",
				"Microsoft PhagsPa", "Microsoft Sans Serif", "Microsoft Tai Le", "Microsoft YaHei",
				"Microsoft Yi Baiti", "MingLiU-ExtB", "Mongolian Baiti", "MS Gothic", "MV Boli", "Myanmar Text",
				"Nirmala UI", "Palatino Linotype", "Segoe MDL2 Assets", "Segoe Print", "Segoe Script", "Segoe UI",
				"Segoe UI Historic", "Segoe UI Emoji", "Segoe UI Symbol", "SimSun", "Sitka", "Sylfaen", "Symbol",
				"Tahoma", "Times New Roman", "Trebuchet MS", "Verdana", "Webdings", "Wingdings", "Yu Gothic"
};

function this.init()
end

function this.draw()
	local cached_config = config.current_config;

	local window_position = Vector2f.new(config.current_config.customization_menu.position.x, config.current_config.customization_menu.position.y);
	local window_pivot = Vector2f.new(config.current_config.customization_menu.pivot.x, config.current_config.customization_menu.pivot.y);
	local window_size = Vector2f.new(config.current_config.customization_menu.size.width, config.current_config.customization_menu.size.height);

	imgui.set_next_window_pos(window_position, 1 << 3, window_pivot);
	imgui.set_next_window_size(window_size, 1 << 3);

	this.is_opened = imgui.begin_window(
		"Damage Numbers v" .. config.current_config.version, this.is_opened, this.window_flags);

	if not this.is_opened then
		imgui.end_window();
		return;
	end

	local changed = false;
	local config_changed = false;
	local window_changed = false;
	local timer_delays_changed = false;
	local index = 1;

	local new_window_position = imgui.get_window_pos();
	if window_position.x ~= new_window_position.x or window_position.y ~= new_window_position.y then
		window_changed = window_changed or true;

		config.current_config.customization_menu.position.x = new_window_position.x;
		config.current_config.customization_menu.position.y = new_window_position.y;
	end

	local new_window_size = imgui.get_window_size();
	if window_size.x ~= new_window_size.x or window_size.y ~= new_window_size.y then
		window_changed = window_changed or true;

		config.current_config.customization_menu.size.width = new_window_size.x;
		config.current_config.customization_menu.size.height = new_window_size.y;
	end

	if imgui.button("Reset Config") then
		config.reset();
		config_changed = true;
	end

	changed, cached_config.enabled = imgui.checkbox("Enabled", cached_config.enabled);
	config_changed = config_changed or changed;

	if imgui.tree_node("Font") then
		imgui.text("Any changes to the font require script reload!");

		changed, index = imgui.combo("Family",
			utils.table.find_index(this.fonts, cached_config.font.family), this.fonts);
		config_changed = config_changed or changed;

		if changed then
			cached_config.font.family = this.fonts[index];
		end

		changed, cached_config.font.size = imgui.slider_int("Size",
			cached_config.font.size, 1, 100);
		config_changed = config_changed or changed;

		changed, cached_config.font.bold = imgui.checkbox("Bold",
			cached_config.font.bold);
		config_changed = config_changed or changed;

		changed, cached_config.font.italic = imgui.checkbox("Italic",
			cached_config.font.italic);
		config_changed = config_changed or changed;

		imgui.tree_pop();

	end

	if imgui.tree_node("Settings") then
		if imgui.tree_node("Timer Delays") then

			changed, cached_config.settings.timer_delays.update_singletons_delay = imgui.drag_float(
				"Update Singletons (sec)",
				cached_config.settings.timer_delays.update_singletons_delay, 0.001, 0, 5, "%.3f");
			
			config_changed = config_changed or changed;
			timer_delays_changed = timer_delays_changed or changed;

			changed, cached_config.settings.timer_delays.update_window_size_delay = imgui.drag_float(
				"Update Window Size (sec)",
				cached_config.settings.timer_delays.update_window_size_delay, 0.001, 0, 5, "%.3f");
			
			config_changed = config_changed or changed;
			timer_delays_changed = timer_delays_changed or changed;
			
			changed, cached_config.settings.timer_delays.update_game_data_delay = imgui.drag_float(
				"Update Game Data (sec)",
				cached_config.settings.timer_delays.update_game_data_delay, 0.001, 0, 5, "%.3f");

			changed, cached_config.settings.timer_delays.update_player_data_delay = imgui.drag_float(
				"Update Player Data (sec)",
				cached_config.settings.timer_delays.update_player_data_delay, 0.001, 0, 5, "%.3f");
			
			config_changed = config_changed or changed;
			timer_delays_changed = timer_delays_changed or changed;

			imgui.tree_pop();
		end

		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.use_d2d_if_available = imgui.checkbox("Use Direct2D Renderer if Available",
			cached_config.settings.use_d2d_if_available);
		config_changed = config_changed or changed;

		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.render_during_cutscenes = imgui.checkbox("Render during Cutscenes",
			cached_config.settings.render_during_cutscenes);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_game_timer_is_paused = imgui.checkbox("Render when Game Timer Is Paused",
			cached_config.settings.render_when_game_timer_is_paused);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_any_menu_is_opened = imgui.checkbox("Render when Any Menu Is Opened",
			cached_config.settings.render_when_any_menu_is_opened);
		config_changed = config_changed or changed;
		
		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()
		
		changed, cached_config.settings.render_when_normal = imgui.checkbox("Render when Normal",
			cached_config.settings.render_when_normal);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_aiming = imgui.checkbox("Render when Aiming",
			cached_config.settings.render_when_aiming);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_guarding = imgui.checkbox("Render when Guarding",
			cached_config.settings.render_when_guarding);
		config_changed = config_changed or changed;

		imgui.end_rect(5);
		imgui.new_line();

		changed, cached_config.settings.display_delay = imgui.drag_float("Display Delay (sec)",
			cached_config.settings.display_delay, 0.001, 0, 100, "%.3f");
		config_changed = config_changed or changed;

		changed, cached_config.settings.display_duration = imgui.drag_float("Display Duration (sec)",
			cached_config.settings.display_duration, 0.001, 0, 100, "%.3f");
		config_changed = config_changed or changed;

		imgui.new_line();

		changed, cached_config.settings.floating_direction.min = imgui.drag_float("Floating Direction (Min)",
			cached_config.settings.floating_direction.min, 0.1, -720, cached_config.settings.floating_direction.max, "%.1f");
		config_changed = config_changed or changed;

		changed, cached_config.settings.floating_direction.max = imgui.drag_float("Floating Direction (Max)",
			cached_config.settings.floating_direction.max, 0.1, cached_config.settings.floating_direction.min, 720, "%.1f");
		config_changed = config_changed or changed;

		imgui.new_line();

		changed, cached_config.settings.floating_distance.min = imgui.drag_float("Floating Distance (Min)",
			cached_config.settings.floating_distance.min, 0.1, 0, cached_config.settings.floating_distance.max, "%.1f");
		config_changed = config_changed or changed;

		changed, cached_config.settings.floating_distance.max = imgui.drag_float("Floating Distance (Max)",
			cached_config.settings.floating_distance.max, 0.1, cached_config.settings.floating_distance.min, 2000, "%.1f");
		config_changed = config_changed or changed;
		
		imgui.tree_pop();
	end

	if imgui.tree_node("Keyframes") then
		changed = keyframe_customization.draw("Opacity", cached_config.keyframes.opacity_scale, 0.001, 0, 1, "%.1f", true);
		config_changed = config_changed or changed;

		changed = keyframe_customization.draw("Floating Movemement", cached_config.keyframes.floating_movement, 0.001, 0, 1, "%.1f", true);
		config_changed = config_changed or changed;

		if imgui.tree_node("Damage Number Label") then
			changed = keyframe_customization.draw("Visibility", cached_config.keyframes.damage_number_label.visibility);
			config_changed = config_changed or changed;
	
			if imgui.tree_node("Offset") then
				changed = keyframe_customization.draw("X", cached_config.keyframes.damage_number_label.offset.x, 0.1, -screen.width, screen.width, "%.1f");
				config_changed = config_changed or changed;
	
				changed = keyframe_customization.draw("Y", cached_config.keyframes.damage_number_label.offset.y, 0.1, -screen.width, screen.width, "%.1f");
				config_changed = config_changed or changed;
	
				imgui.tree_pop();
			end
	
			changed = keyframe_customization.draw("Color", cached_config.keyframes.damage_number_label.color);
			config_changed = config_changed or changed;
	
			if imgui.tree_node("Shadow") then
				changed = keyframe_customization.draw("Visibility", cached_config.keyframes.damage_number_label.shadow.visibility);
				config_changed = config_changed or changed;
	
				if imgui.tree_node("Offset") then
					changed = keyframe_customization.draw("X", cached_config.keyframes.damage_number_label.shadow.offset.x, 0.1, -screen.width, screen.width, "%.1f");
					config_changed = config_changed or changed;
	
					changed = keyframe_customization.draw("Y", cached_config.keyframes.damage_number_label.shadow.offset.y, 0.1, -screen.width, screen.width, "%.1f");
					config_changed = config_changed or changed;
	
					imgui.tree_pop();
				end
	
				changed = keyframe_customization.draw("Color", cached_config.keyframes.damage_number_label.shadow.color);
				config_changed = config_changed or changed;
	
				imgui.tree_pop();
			end
			
			imgui.tree_pop();
		end
		
		imgui.tree_pop();
	end

	changed = this.draw_debug();
	config_changed = config_changed or changed;

	imgui.new_line();
	imgui.end_window();

	if config_changed or window_changed then
		config.save();
	end
end

function this.draw_debug()
	local cached_config = config.current_config.debug;

	local changed = false;
	local config_changed = false;

	if imgui.tree_node("Debug") then
		
		imgui.text_colored("Current Time:", 0xFFAAAA66);
		imgui.same_line();
		imgui.text(string.format("%.3fs", time.total_elapsed_script_seconds));

		if error_handler.is_empty then
			imgui.text("Everything seems to be OK!");
		else
			for error_key, error in pairs(error_handler.list) do

				imgui.button(string.format("%.3fs", error.time));
				imgui.same_line();
				imgui.text_colored(error_key, 0xFFAA66AA);
				imgui.same_line();
				imgui.text(error.message);
			end
		end

		if imgui.tree_node("History") then

			changed, cached_config.history_size = imgui.drag_int(
				"History Size", cached_config.history_size, 1, 0, 1024);

			config_changed = config_changed or changed;

			if changed then
				error_handler.history = {};
			end

			for index, error in pairs(error_handler.history) do
				imgui.text_colored(index, 0xFF66AA66);
				imgui.same_line();
				imgui.button(string.format("%.3fs", error.time));
				imgui.same_line();
				imgui.text_colored(error.key, 0xFFAA66AA);
				imgui.same_line();
				imgui.text(error.message);
			end


			imgui.tree_pop();
		end

		imgui.tree_pop();
	end

	return config_changed;
end


function this.init_module()
	utils = require("Damage_Numbers.utils");
	config = require("Damage_Numbers.config");
	screen = require("Damage_Numbers.screen");
	keyframe_customization = require("Damage_Numbers.keyframe_customization");
	time = require("Damage_Numbers.time");
	error_handler = require("Damage_Numbers.error_handler");

	this.init();
end

return this;