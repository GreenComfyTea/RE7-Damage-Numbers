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
local ValueType = ValueType;
local package = package;

local time = require("Damage_Numbers.time");
local drawing = require("Damage_Numbers.drawing");
local utils = require("Damage_Numbers.utils");
local config = require("Damage_Numbers.config");
local screen = require("Damage_Numbers.screen");
local singletons = require("Damage_Numbers.singletons");
local error_handler = require("Damage_Numbers.error_handler");

local keyframe_customization = require("Damage_Numbers.keyframe_customization");
local customization_menu = require("Damage_Numbers.customization_menu");

local keyframe_handler = require("Damage_Numbers.keyframe_handler");
local damage_handler = require("Damage_Numbers.damage_handler");
local game_handler = require("Damage_Numbers.game_handler");
local player_handler = require("Damage_Numbers.player_handler");

------------------------INIT MODULES-------------------------
-- #region
time.init_module();
drawing.init_module();
utils.init_module();
config.init_module();
screen.init_module();
singletons.init_module();
error_handler.init_module();

keyframe_customization.init_module();
customization_menu.init_module();

keyframe_handler.init_module();
damage_handler.init_module();

game_handler.init_module();
player_handler.init_module();

log.info("[Damage Numbers] Loaded.");
-- #endregion
------------------------INIT MODULES-------------------------

----------------------------LOOP-----------------------------
-- #region
re.on_pre_application_entry("UpdateBehavior", function()
	if not config.current_config.enabled then
		return;
	end

	time.update_timers();
end);

local function main_loop()
	if not config.current_config.enabled then
		return;
	end

	damage_handler.tick();
end

-- #endregion
----------------------------LOOP-----------------------------

--------------------------RE_IMGUI---------------------------
-- #region
re.on_draw_ui(function()
	local changed = false;
	local cached_config = config.current_config;

	if imgui.button("Damage Numbers v" .. config.current_config.version .. "##DAMAGE_NUMBERS") then
		customization_menu.is_opened = not customization_menu.is_opened;
	end

	imgui.same_line();

	changed, cached_config.enabled = imgui.checkbox("Enabled##DAMAGE_NUMBERS", cached_config.enabled);
	if changed then
		config.save();
	end
end);

re.on_frame(function()
	if not reframework:is_drawing_ui() then
		customization_menu.is_opened = false;
	end

	if customization_menu.is_opened then
		pcall(customization_menu.draw);
	end
end);
-- #endregion
--------------------------RE_IMGUI---------------------------

----------------------------D2D------------------------------
-- #region
if d2d ~= nil then
	d2d.register(function()
		drawing.init_font();
	end, function() 
		if config.current_config.settings.use_d2d_if_available then
			main_loop();
		end
	end);
end

re.on_frame(function()
	if d2d == nil or not config.current_config.settings.use_d2d_if_available then
		main_loop();
	end
end);
-- #endregion
----------------------------D2D------------------------------

time.init_global_timers();