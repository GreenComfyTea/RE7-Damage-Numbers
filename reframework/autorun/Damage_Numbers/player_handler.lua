local this = {};

local utils;
local singletons;
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

this.player = {};
this.player.is_aiming = false;
this.player.is_guarding = false;

-- local player_manager_type_def = sdk.find_type_definition("app.PlayerManager");
-- local get_current_position_method = player_manager_type_def:get_method("get_CurrentPosition");
-- local get_current_player_condition_method = player_manager_type_def:get_method("get_CurrentPlayerCondition");

-- local player_condition_type_def = get_current_player_condition_method:get_return_type();
-- local get_is_hold_method = player_condition_type_def:get_method("get_IsHold");

local inventory_manager_type_def = sdk.find_type_definition("app.InventoryManager");
local inventory_field = inventory_manager_type_def:get_field("_Inventory");

local inventory_type_def = inventory_field:get_type();
local player_status_field = inventory_type_def:get_field("PlayerStatus");

local player_status_type_def = sdk.find_type_definition("app.PlayerStatus");
local get_is_aim_method = player_status_type_def:get_method("get_IsAim");
local get_is_guard_method = player_status_type_def:get_method("get_isGuard");

function this.update()
	local inventory_manager = singletons.inventory_manager;
	if inventory_manager == nil then
		error_handler.report("player_handler.update", "No InventoryManager");
		return;
	end

	local inventory = inventory_field:get_data(inventory_manager);
	if inventory == nil then
		error_handler.report("player_handler.update", "No Inventory");
		return;
	end

	local player_status = player_status_field:get_data(inventory);
	if player_status == nil then
		error_handler.report("player_handler.update", "No PlayerStatus");
		return;
	end

	this.update_is_aiming(player_status);
	this.update_is_guarding(player_status);
end

function this.update_is_aiming(player_status)
	local is_aim = get_is_aim_method:call(player_status);
	if is_aim == nil then
		error_handler.report("player_handler.update_is_aiming", "No IsAim");
		return;
	end

	this.player.is_aiming = is_aim;
end

function this.update_is_guarding(player_status)
	local is_guard = get_is_guard_method:call(player_status);
	if is_guard == nil then
		error_handler.report("player_handler.update_is_guarding", "No IsGuard");
		return;
	end

	this.player.is_guarding = is_guard;
end

function this.init_module()
	utils = require("Damage_Numbers.utils");
	singletons = require("Damage_Numbers.singletons");
	error_handler = require("Damage_Numbers.error_handler");
end

return this;