local this = {};
local version = "1.0";

local utils;

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

this.current_config = nil;
this.config_file_name = "Damage Numbers/config.json";

this.default_config = {};

function this.init()
	this.default_config = {
		enabled = true,

		version = this.version,

		customization_menu = {
			position = {
				x = 480,
				y = 200
			},

			size = {
				width = 730,
				height = 550
			},

			pivot = {
				x = 0,
				y = 0
			}
		},

		font = {
			family = "Bahnschrift",
			size = 24,
			bold = true,
			italic = false
		},

		settings = {
			timer_delays = {
				update_singletons_delay = 0,
				update_window_size_delay = 0,
				update_game_data_delay = 0.1,
				update_player_data_delay = 0.1
			},

			use_d2d_if_available = true,

			render_during_cutscenes = false,
			render_when_paused = false,

			render_when_normal = true,
			render_when_aiming = true,
			render_when_guarding = true,

			display_delay = 0.022222,
			-- display_duration = 0.988888,

			--display_delay = 0.116666,
			--display_delay = 0.0,
			display_duration = 0.650,

			floating_direction = {
				min = -105,
				max = -75
			},

			floating_distance = {
				min = 50,
				max = 100
			}
		},

		keyframes = {
			opacity_scale = {
				type = "float",
				current_keyframe_index = 1,
				[1] = {
	
					timeline_position = 0,
					value = 0,
				},
				[2] = {
	
					timeline_position = 0.166666,
					value = 1,
				},
				[3] = {
	
					timeline_position = 0.666666,
					value = 1,
				},
				[4] = {
	
					timeline_position = 1,
					value = 0,
				},
			},

			floating_movement = {
				type = "float",
				current_keyframe_index = 1,
				[1] = {
					timeline_position = 0,
					value = 0,
				},
				[2] = {
					timeline_position = 1,
					value = 1,
				},
			},

			damage_number_label = {
				visibility = {
					type = "bool",
					current_keyframe_index = 1,
					[1] = {
						timeline_position = 0,
						value = true,
					}
				},
	
				offset = {
					x = {
						type = "float",
						current_keyframe_index = 1,
						[1] = {
							timeline_position = 0,
							value = 0,
	
						}
					},
	
					y = {
						type = "float",
						current_keyframe_index = 1,
						[1] = {
							timeline_position = 0,
							value = 0,
						}
					},
				},
				
				color = {
					type = "color",
					current_keyframe_index = 1,
					[1] = {
						timeline_position = 0,
						value = 0xB9FFF7F2,
					}
				},
	
				shadow = {
					visibility = {
						type = "bool",
						current_keyframe_index = 1,
						[1] = {
							timeline_position = 0,
							value = true,
						}
					},
	
					offset = {
						x = {
							type = "float",
							current_keyframe_index = 1,
							[1] = {
								timeline_position = 0,
								value = 1,
							}
						},
	
						y = {
							type = "float",
							current_keyframe_index = 1,
							[1] = {
								timeline_position = 0,
								value = 1,
							}
						},
					},
	
					color = {
						type = "color",
						current_keyframe_index = 1,
						[1] = {
							timeline_position = 0,
							value = 0xFF000000,
						}
					}
				}
			},
		},

		damage_number_label = {
			visibility = true,

			text_format = "%s", -- current_health/max_health

			offset = {
				x = 0,
				y = 0
			},
			
			color = 0xFFFFFFFF,

			shadow = {
				visibility = true,
				offset = {
					x = 1,
					y = 1
				},
				color = 0xFF000000
			}
		},

		debug = {
			history_size = 64
		}
	};
end

function this.load()
	local loaded_config = json.load_file(this.config_file_name);
	if loaded_config ~= nil then
		log.info("[Damage Numbers] config.json loaded successfully");
		this.current_config = utils.table.merge(this.default_config, loaded_config);
		this.fix_string_indices();
	else
		log.error("[Damage Numbers] Failed to load config.json");
		this.current_config = utils.table.deep_copy(this.default_config);
	end
end

function this.save()
	-- save current config to disk, replacing any existing file
	local success = json.dump_file(this.config_file_name, this.current_config);
	if success then
		log.info("[Damage Numbers] config.json saved successfully");
	else
		log.error("[Damage Numbers] Failed to save config.json");
	end
end

function this.reset()
	this.current_config = utils.table.deep_copy(this.default_config);
	this.current_config.version = version;
end

function this.fix_string_indices()
	local keyframes = this.current_config.keyframes;
	local damage_number_label_keyframes = keyframes.damage_number_label;
	local damage_number_label_shadow_keyframes = damage_number_label_keyframes.shadow;

	keyframes.opacity_scale = this.fix_string_indices_(keyframes.opacity_scale);
	keyframes.floating_movement = this.fix_string_indices_(keyframes.floating_movement);

	damage_number_label_keyframes.visibility = this.fix_string_indices_(damage_number_label_keyframes.visibility);
	damage_number_label_keyframes.offset.x = this.fix_string_indices_(damage_number_label_keyframes.offset.x);
	damage_number_label_keyframes.offset.y = this.fix_string_indices_(damage_number_label_keyframes.offset.y);
	damage_number_label_keyframes.color = this.fix_string_indices_(damage_number_label_keyframes.color);

	damage_number_label_shadow_keyframes.visibility = this.fix_string_indices_(damage_number_label_shadow_keyframes.visibility);
	damage_number_label_shadow_keyframes.offset.x = this.fix_string_indices_(damage_number_label_shadow_keyframes.offset.x);
	damage_number_label_shadow_keyframes.offset.y = this.fix_string_indices_(damage_number_label_shadow_keyframes.offset.y);
	damage_number_label_shadow_keyframes.color = this.fix_string_indices_(damage_number_label_shadow_keyframes.color);
end

function this.fix_string_indices_(keyframes)
	local fixed_keyframes = {};
	for key, value in pairs(keyframes) do
		local index = tonumber(key);

		if index ~= nil then
			fixed_keyframes[index] = value;
		else
			fixed_keyframes[key] = value;
		end
	end

	return fixed_keyframes;
end

function this.init_module()
	utils = require("Damage_Numbers.utils");

	this.init();
	this.load();
	this.current_config.version = version;
end

return this;
