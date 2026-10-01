@tool
extends "res://addons/godot_mcp/tools/base_tools.gd"

## Project management tools for Godot MCP
## Provides project settings, export, and configuration management


func get_tools() -> Array[Dictionary]:
	return [
		{
			"name": "info",
			"description": """PROJECT INFO: Get information about the current Godot project.

ACTIONS:
- get_info: Get basic project information
- get_settings: Get project settings
- get_features: Get enabled project features
- get_export_presets: Get configured export presets
- get_structure: Count files by category (scenes/scripts/assets/...) in the project

EXAMPLES:
- Get project info: {"action": "get_info"}
- Get settings: {"action": "get_settings"}
- Get file statistics: {"action": "get_structure"}
- Get specific setting: {"action": "get_settings", "setting": "application/config/name"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["get_info", "get_settings", "get_features", "get_export_presets", "get_structure"],
						"description": "Info action"
					},
					"setting": {
						"type": "string",
						"description": "Specific setting path to retrieve"
					}
				},
				"required": ["action"]
			}
		},
		{
			"name": "settings",
			"description": """PROJECT SETTINGS: Modify project settings.

ACTIONS:
- set: Set a project setting value
- reset: Reset setting to default
- list_category: List all settings in a category

COMMON SETTINGS:
- application/config/name: Project name
- application/config/description: Project description
- application/run/main_scene: Main scene path
- display/window/size/viewport_width: Window width
- display/window/size/viewport_height: Window height
- rendering/renderer/rendering_method: Renderer (forward_plus, mobile, gl_compatibility)
- physics/2d/default_gravity: 2D gravity
- physics/3d/default_gravity: 3D gravity

CATEGORIES:
- application
- display
- rendering
- physics
- input
- audio
- network
- debug

EXAMPLES:
- Set project name: {"action": "set", "setting": "application/config/name", "value": "My Game"}
- Set window size: {"action": "set", "setting": "display/window/size/viewport_width", "value": 1920}
- List display settings: {"action": "list_category", "category": "display"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["set", "reset", "list_category"],
						"description": "Settings action"
					},
					"setting": {
						"type": "string",
						"description": "Setting path"
					},
					"value": {
						"description": "New value for setting"
					},
					"category": {
						"type": "string",
						"description": "Category to list"
					}
				},
				"required": ["action"]
			}
		},
		{
			"name": "input",
			"description": """INPUT MAP: Manage input actions and bindings.

ACTIONS:
- list_actions: List all input actions
- get_action: Get bindings for an action
- add_action: Add a new input action
- remove_action: Remove an input action
- add_binding: Add a binding to an action
- remove_binding: Remove a binding from an action

INPUT TYPES:
- key: Keyboard key (e.g., "A", "Space", "Enter", "Escape")
- mouse: Mouse button (e.g., "left", "right", "middle")
- joypad_button: Gamepad button (e.g., 0 for A/Cross)
- joypad_axis: Gamepad axis (e.g., 0 for left stick X)

EXAMPLES:
- List actions: {"action": "list_actions"}
- Add action: {"action": "add_action", "name": "jump"}
- Add key binding: {"action": "add_binding", "name": "jump", "type": "key", "key": "Space"}
- Add mouse binding: {"action": "add_binding", "name": "shoot", "type": "mouse", "button": "left"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["list_actions", "get_action", "add_action", "remove_action", "add_binding", "remove_binding"],
						"description": "Input action"
					},
					"name": {
						"type": "string",
						"description": "Action name"
					},
					"type": {
						"type": "string",
						"enum": ["key", "mouse", "joypad_button", "joypad_axis"],
						"description": "Input type"
					},
					"key": {
						"type": "string",
						"description": "Key name for keyboard input"
					},
					"button": {
						"type": "string",
						"description": "Button for mouse/joypad"
					},
					"axis": {
						"type": "integer",
						"description": "Axis index for joypad"
					}
				},
				"required": ["action"]
			}
		},
		{
			"name": "autoload",
			"description": """AUTOLOAD: Manage autoloaded scripts and scenes.

ACTIONS:
- list: List all autoloads
- add: Add a new autoload
- remove: Remove an autoload
- reorder: Change autoload order

EXAMPLES:
- List autoloads: {"action": "list"}
- Add autoload: {"action": "add", "name": "GameManager", "path": "res://scripts/game_manager.gd"}
- Remove autoload: {"action": "remove", "name": "GameManager"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["list", "add", "remove", "reorder"],
						"description": "Autoload action"
					},
					"name": {
						"type": "string",
						"description": "Autoload name"
					},
					"path": {
						"type": "string",
						"description": "Script/scene path"
					},
					"index": {
						"type": "integer",
						"description": "New index for reorder"
					}
				},
				"required": ["action"]
			}
		},
		{
			"name": "discovery",
			"description": """PROJECT DISCOVERY: Find Godot projects on disk.
Migrated from the bradypp/godot-mcp "list_projects" tool.

ACTIONS:
- find_projects: Scan a directory for folders containing project.godot
- get_project_file: Read the raw project.godot of a directory

NOTES:
- Unlike filesystem_search (which only sees res:// / user://), this tool can walk
  any absolute path on the machine, so it can discover sibling projects.
- Directories starting with "." plus node_modules and (optionally) addons are skipped.

EXAMPLES:
- Scan a workspace: {"action": "find_projects", "directory": "D:/Projects", "recursive": true, "max_depth": 3}
- Non-recursive: {"action": "find_projects", "directory": "D:/Projects", "recursive": false}
- Read the project file: {"action": "get_project_file", "path": "D:/Projects/MyGame"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["find_projects", "get_project_file"],
						"description": "Discovery action"
					},
					"directory": {
						"type": "string",
						"description": "Absolute directory to scan (or res:// / user://)"
					},
					"path": {
						"type": "string",
						"description": "Project directory for get_project_file"
					},
					"recursive": {
						"type": "boolean",
						"description": "Scan subdirectories (default: true)"
					},
					"max_depth": {
						"type": "integer",
						"description": "Maximum recursion depth (default: 4)"
					},
					"limit": {
						"type": "integer",
						"description": "Maximum number of projects to return (default: 100)"
					},
					"include_addons": {
						"type": "boolean",
						"description": "Scan inside addons/ folders (default: false)"
					}
				},
				"required": ["action"]
			}
		}
	]


func execute(tool_name: String, args: Dictionary) -> Dictionary:
	match tool_name:
		"info":
			return _execute_info(args)
		"settings":
			return _execute_settings(args)
		"input":
			return _execute_input(args)
		"autoload":
			return _execute_autoload(args)
		"discovery":
			return _execute_discovery(args)
		_:
			return _error("Unknown tool: %s" % tool_name)


# ==================== INFO ====================

func _execute_info(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"get_info":
			return _get_project_info()
		"get_settings":
			return _get_project_settings(args.get("setting", ""))
		"get_features":
			return _get_features()
		"get_export_presets":
			return _get_export_presets()
		"get_structure":
			return _get_project_structure()
		_:
			return _error("Unknown action: %s" % action)


func _get_project_info() -> Dictionary:
	var version_info = Engine.get_version_info()
	var info = {
		"name": str(ProjectSettings.get_setting("application/config/name", "Untitled")),
		"description": str(ProjectSettings.get_setting("application/config/description", "")),
		"version": str(ProjectSettings.get_setting("application/config/version", "")),
		"main_scene": str(ProjectSettings.get_setting("application/run/main_scene", "")),
		"godot_version": "%d.%d.%d" % [version_info.get("major", 0), version_info.get("minor", 0), version_info.get("patch", 0)],
		"godot_version_string": str(version_info.get("string", "")),
		"project_path": ProjectSettings.globalize_path("res://"),
		"renderer": str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")),
		"window": {
			"width": int(ProjectSettings.get_setting("display/window/size/viewport_width", 1152)),
			"height": int(ProjectSettings.get_setting("display/window/size/viewport_height", 648)),
			"mode": int(ProjectSettings.get_setting("display/window/size/mode", 0)),
			"resizable": bool(ProjectSettings.get_setting("display/window/size/resizable", true))
		}
	}

	return _success(info)


func _get_project_settings(setting: String) -> Dictionary:
	if not setting.is_empty():
		if not ProjectSettings.has_setting(setting):
			return _error("Setting not found: %s" % setting)

		var value = ProjectSettings.get_setting(setting)
		# Convert to JSON-safe value
		if typeof(value) == TYPE_OBJECT:
			value = str(value)

		return _success({
			"setting": setting,
			"value": value
		})

	# Return common settings
	var settings = {}
	var common_settings = [
		"application/config/name",
		"application/config/description",
		"application/run/main_scene",
		"display/window/size/viewport_width",
		"display/window/size/viewport_height",
		"rendering/renderer/rendering_method",
		"physics/2d/default_gravity",
		"physics/3d/default_gravity"
	]

	for s in common_settings:
		if ProjectSettings.has_setting(s):
			settings[s] = ProjectSettings.get_setting(s)

	return _success({"settings": settings})


func _get_features() -> Dictionary:
	# Get project features
	var features: Array[String] = []

	# Check for common features
	if ProjectSettings.has_setting("application/config/features"):
		var f = ProjectSettings.get_setting("application/config/features")
		if f is PackedStringArray:
			for feature in f:
				features.append(feature)

	return _success({
		"features": features,
		"os": OS.get_name(),
		"debug": OS.is_debug_build()
	})


func _get_export_presets() -> Dictionary:
	# Export presets are in export_presets.cfg
	var presets: Array[Dictionary] = []

	var preset_path = "res://export_presets.cfg"
	if FileAccess.file_exists(preset_path):
		var config = ConfigFile.new()
		var err = config.load(preset_path)
		if err == OK:
			for section in config.get_sections():
				if section.begins_with("preset."):
					presets.append({
						"name": config.get_value(section, "name", ""),
						"platform": config.get_value(section, "platform", ""),
						"export_path": config.get_value(section, "export_path", "")
					})

	return _success({
		"count": presets.size(),
		"presets": presets
	})


# ==================== SETTINGS ====================

func _execute_settings(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"set":
			return _set_setting(args.get("setting", ""), args.get("value"))
		"reset":
			return _reset_setting(args.get("setting", ""))
		"list_category":
			return _list_category(args.get("category", ""))
		_:
			return _error("Unknown action: %s" % action)


func _set_setting(setting: String, value) -> Dictionary:
	if setting.is_empty():
		return _error("Setting path is required")

	ProjectSettings.set_setting(setting, value)
	var error = ProjectSettings.save()

	if error != OK:
		return _error("Failed to save project settings")

	return _success({
		"setting": setting,
		"value": value
	}, "Setting updated")


func _reset_setting(setting: String) -> Dictionary:
	if setting.is_empty():
		return _error("Setting path is required")

	if not ProjectSettings.has_setting(setting):
		return _error("Setting not found: %s" % setting)

	ProjectSettings.set_setting(setting, null)
	var error = ProjectSettings.save()

	if error != OK:
		return _error("Failed to save project settings")

	return _success({"setting": setting}, "Setting reset to default")


func _list_category(category: String) -> Dictionary:
	if category.is_empty():
		return _error("Category is required")

	var settings: Dictionary = {}
	var property_list = ProjectSettings.get_property_list()

	for prop in property_list:
		var prop_name = str(prop.name)
		if prop_name.begins_with(category + "/"):
			settings[prop_name] = ProjectSettings.get_setting(prop_name)

	return _success({
		"category": category,
		"count": settings.size(),
		"settings": settings
	})


# ==================== INPUT ====================

func _execute_input(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"list_actions":
			return _list_input_actions()
		"get_action":
			return _get_input_action(args.get("name", ""))
		"add_action":
			return _add_input_action(args.get("name", ""))
		"remove_action":
			return _remove_input_action(args.get("name", ""))
		"add_binding":
			return _add_input_binding(args)
		"remove_binding":
			return _remove_input_binding(args)
		_:
			return _error("Unknown action: %s" % action)


func _list_input_actions() -> Dictionary:
	var actions: Array[Dictionary] = []
	var property_list = ProjectSettings.get_property_list()

	for prop in property_list:
		var prop_name = str(prop.name)
		if prop_name.begins_with("input/"):
			var action_name = prop_name.substr(6)  # Remove "input/" prefix
			var action_data = ProjectSettings.get_setting(prop_name)

			if action_data is Dictionary:
				var events = action_data.get("events", [])
				actions.append({
					"name": action_name,
					"deadzone": action_data.get("deadzone", 0.5),
					"event_count": events.size()
				})

	return _success({
		"count": actions.size(),
		"actions": actions
	})


func _get_input_action(name: String) -> Dictionary:
	if name.is_empty():
		return _error("Action name is required")

	var setting_path = "input/" + name
	if not ProjectSettings.has_setting(setting_path):
		return _error("Action not found: %s" % name)

	var action_data = ProjectSettings.get_setting(setting_path)
	var events_info: Array[Dictionary] = []

	if action_data is Dictionary:
		var events = action_data.get("events", [])
		for event in events:
			events_info.append(_event_to_dict(event))

	return _success({
		"name": name,
		"deadzone": action_data.get("deadzone", 0.5) if action_data is Dictionary else 0.5,
		"events": events_info
	})


func _add_input_action(name: String) -> Dictionary:
	if name.is_empty():
		return _error("Action name is required")

	var setting_path = "input/" + name
	if ProjectSettings.has_setting(setting_path):
		return _error("Action already exists: %s" % name)

	ProjectSettings.set_setting(setting_path, {
		"deadzone": 0.5,
		"events": []
	})

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({"name": name}, "Input action added")


func _remove_input_action(name: String) -> Dictionary:
	if name.is_empty():
		return _error("Action name is required")

	var setting_path = "input/" + name
	if not ProjectSettings.has_setting(setting_path):
		return _error("Action not found: %s" % name)

	ProjectSettings.set_setting(setting_path, null)

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({"name": name}, "Input action removed")


func _add_input_binding(args: Dictionary) -> Dictionary:
	var name = args.get("name", "")
	var type = args.get("type", "")

	if name.is_empty():
		return _error("Action name is required")
	if type.is_empty():
		return _error("Input type is required")

	var setting_path = "input/" + name
	if not ProjectSettings.has_setting(setting_path):
		return _error("Action not found: %s" % name)

	var action_data = ProjectSettings.get_setting(setting_path)
	if not action_data is Dictionary:
		action_data = {"deadzone": 0.5, "events": []}

	var events = action_data.get("events", [])
	var new_event: InputEvent

	match type:
		"key":
			new_event = InputEventKey.new()
			var key_string = args.get("key", "")
			if key_string.is_empty():
				return _error("Key is required for keyboard input")
			new_event.keycode = OS.find_keycode_from_string(key_string)
		"mouse":
			new_event = InputEventMouseButton.new()
			var button = args.get("button", "left")
			match button:
				"left":
					new_event.button_index = MOUSE_BUTTON_LEFT
				"right":
					new_event.button_index = MOUSE_BUTTON_RIGHT
				"middle":
					new_event.button_index = MOUSE_BUTTON_MIDDLE
		"joypad_button":
			new_event = InputEventJoypadButton.new()
			new_event.button_index = args.get("button", 0)
		"joypad_axis":
			new_event = InputEventJoypadMotion.new()
			new_event.axis = args.get("axis", 0)
			new_event.axis_value = args.get("axis_value", 1.0)
		_:
			return _error("Unknown input type: %s" % type)

	events.append(new_event)
	action_data["events"] = events
	ProjectSettings.set_setting(setting_path, action_data)

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({
		"name": name,
		"type": type,
		"event_count": events.size()
	}, "Input binding added")


func _remove_input_binding(args: Dictionary) -> Dictionary:
	var name = args.get("name", "")
	var index = args.get("index", -1)

	if name.is_empty():
		return _error("Action name is required")
	if index < 0:
		return _error("Binding index is required")

	var setting_path = "input/" + name
	if not ProjectSettings.has_setting(setting_path):
		return _error("Action not found: %s" % name)

	var action_data = ProjectSettings.get_setting(setting_path)
	if not action_data is Dictionary:
		return _error("Invalid action data")

	var events = action_data.get("events", [])
	if index >= events.size():
		return _error("Binding index out of range")

	events.remove_at(index)
	action_data["events"] = events
	ProjectSettings.set_setting(setting_path, action_data)

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({
		"name": name,
		"removed_index": index
	}, "Input binding removed")


func _event_to_dict(event: InputEvent) -> Dictionary:
	var result = {"type": str(event.get_class())}

	if event is InputEventKey:
		result["keycode"] = event.keycode
		result["key_name"] = str(OS.get_keycode_string(event.keycode))
	elif event is InputEventMouseButton:
		result["button"] = event.button_index
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				result["button_name"] = "left"
			MOUSE_BUTTON_RIGHT:
				result["button_name"] = "right"
			MOUSE_BUTTON_MIDDLE:
				result["button_name"] = "middle"
	elif event is InputEventJoypadButton:
		result["button"] = event.button_index
	elif event is InputEventJoypadMotion:
		result["axis"] = event.axis
		result["axis_value"] = event.axis_value

	return result


# ==================== AUTOLOAD ====================

func _execute_autoload(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"list":
			return _list_autoloads()
		"add":
			return _add_autoload(args.get("name", ""), args.get("path", ""))
		"remove":
			return _remove_autoload(args.get("name", ""))
		_:
			return _error("Unknown action: %s" % action)


func _list_autoloads() -> Dictionary:
	var autoloads: Array[Dictionary] = []
	var property_list = ProjectSettings.get_property_list()

	for prop in property_list:
		var prop_name = str(prop.name)
		if prop_name.begins_with("autoload/"):
			var autoload_name = prop_name.substr(9)  # Remove "autoload/" prefix
			var path_value = str(ProjectSettings.get_setting(prop_name))
			# Path format is "*res://..." where * means singleton
			var is_singleton = path_value.begins_with("*")
			if is_singleton:
				path_value = path_value.substr(1)

			autoloads.append({
				"name": autoload_name,
				"path": path_value,
				"singleton": is_singleton
			})

	return _success({
		"count": autoloads.size(),
		"autoloads": autoloads
	})


func _add_autoload(name: String, path: String) -> Dictionary:
	if name.is_empty():
		return _error("Autoload name is required")
	if path.is_empty():
		return _error("Path is required")

	if not path.begins_with("res://"):
		path = "res://" + path

	var setting_path = "autoload/" + name
	if ProjectSettings.has_setting(setting_path):
		return _error("Autoload already exists: %s" % name)

	# Add with singleton prefix
	ProjectSettings.set_setting(setting_path, "*" + path)

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({
		"name": name,
		"path": path
	}, "Autoload added")


func _remove_autoload(name: String) -> Dictionary:
	if name.is_empty():
		return _error("Autoload name is required")

	var setting_path = "autoload/" + name
	if not ProjectSettings.has_setting(setting_path):
		return _error("Autoload not found: %s" % name)

	ProjectSettings.set_setting(setting_path, null)

	var error = ProjectSettings.save()
	if error != OK:
		return _error("Failed to save project settings")

	return _success({"name": name}, "Autoload removed")


# ==================== STRUCTURE ====================

const IMAGE_AND_AUDIO_EXTENSIONS := [
	"png", "jpg", "jpeg", "webp", "svg", "bmp", "tga",
	"ttf", "otf", "wav", "mp3", "ogg", "glb", "gltf", "obj", "fbx"
]

const RESOURCE_EXTENSIONS := ["tres", "res", "material", "theme", "anim"]
const SCRIPT_EXTENSIONS := ["gd", "cs", "gdscript"]
const SCENE_EXTENSIONS := ["tscn", "scn"]
const SHADER_EXTENSIONS := ["gdshader", "shader"]


func _get_project_structure() -> Dictionary:
	var stats = _scan_project_structure("res://", 0)
	stats["project_path"] = ProjectSettings.globalize_path("res://")
	return _success(stats)


func _scan_project_structure(dir_path: String, depth: int) -> Dictionary:
	var stats = {
		"scenes": 0,
		"scripts": 0,
		"assets": 0,
		"shaders": 0,
		"resources": 0,
		"other": 0,
		"files": 0,
		"bytes": 0
	}

	# Guard against runaway recursion on deeply nested or looping structures
	if depth > 32:
		return stats

	var dir = DirAccess.open(dir_path)
	if not dir:
		return stats

	dir.list_dir_begin()
	var entry = dir.get_next()

	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		var full_path = dir_path.path_join(entry)

		if dir.current_is_dir():
			var sub_stats = _scan_project_structure(full_path, depth + 1)
			for key in sub_stats:
				stats[key] += sub_stats[key]
		else:
			var extension = full_path.get_extension().to_lower()
			stats["files"] += 1

			if extension in SCENE_EXTENSIONS:
				stats["scenes"] += 1
			elif extension in SCRIPT_EXTENSIONS:
				stats["scripts"] += 1
			elif extension in IMAGE_AND_AUDIO_EXTENSIONS:
				stats["assets"] += 1
			elif extension in SHADER_EXTENSIONS:
				stats["shaders"] += 1
			elif extension in RESOURCE_EXTENSIONS:
				stats["resources"] += 1
			else:
				stats["other"] += 1

			stats["bytes"] += _get_file_size(full_path)

		entry = dir.get_next()

	dir.list_dir_end()

	return stats


func _get_file_size(path: String) -> int:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return 0
	var size = file.get_length()
	file.close()
	return size


# ==================== DISCOVERY ====================

func _execute_discovery(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"find_projects":
			return _find_projects(args)
		"get_project_file":
			return _get_project_file(str(args.get("path", "")))
		_:
			return _error("Unknown action: %s" % action)


func _find_projects(args: Dictionary) -> Dictionary:
	var directory = str(args.get("directory", ""))
	if directory.is_empty():
		return _error("directory is required")

	var abs_dir = _resolve_absolute_dir(directory)
	if abs_dir.is_empty():
		return _error("Invalid directory: %s" % directory)
	if not DirAccess.dir_exists_absolute(abs_dir):
		return _error("Directory not found: %s" % abs_dir)

	var recursive: bool = args.get("recursive", true)
	var max_depth: int = int(args.get("max_depth", 4))
	var limit: int = int(args.get("limit", 100))
	var include_addons: bool = args.get("include_addons", false)

	var results: Array[Dictionary] = []
	_scan_for_projects(abs_dir, 0, recursive, max_depth, limit, include_addons, results)

	var current_dir = ProjectSettings.globalize_path("res://").simplify_path()
	for project in results:
		project["is_current"] = str(project["path"]).simplify_path() == current_dir

	return _success({
		"directory": abs_dir,
		"recursive": recursive,
		"count": results.size(),
		"projects": results
	})


func _scan_for_projects(
	dir_path: String,
	depth: int,
	recursive: bool,
	max_depth: int,
	limit: int,
	include_addons: bool,
	results: Array[Dictionary]
) -> void:
	if results.size() >= limit or depth > max_depth:
		return

	if FileAccess.file_exists(dir_path.path_join("project.godot")):
		results.append(_describe_project(dir_path))

	if not recursive or results.size() >= limit:
		return

	var dir = DirAccess.open(dir_path)
	if not dir:
		return

	dir.list_dir_begin()
	var entry = dir.get_next()

	while entry != "" and results.size() < limit:
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		if dir.current_is_dir():
			var skip = entry == "node_modules" or (entry == "addons" and not include_addons)
			if not skip:
				_scan_for_projects(
					dir_path.path_join(entry), depth + 1, recursive, max_depth, limit, include_addons, results
				)

		entry = dir.get_next()

	dir.list_dir_end()


func _describe_project(abs_dir: String) -> Dictionary:
	var project_file = abs_dir.path_join("project.godot")
	var project_name = abs_dir.get_file()
	var main_scene := ""
	var features: Array[String] = []

	var config = ConfigFile.new()
	if config.load(project_file) == OK:
		if config.has_section_key("application", "config/name"):
			project_name = str(config.get_value("application", "config/name"))
		if config.has_section_key("application", "run/main_scene"):
			main_scene = str(config.get_value("application", "run/main_scene"))
		if config.has_section_key("application", "config/features"):
			var raw_features = config.get_value("application", "config/features", PackedStringArray())
			if raw_features is PackedStringArray or raw_features is Array:
				for feature in raw_features:
					features.append(str(feature))

	return {
		"path": abs_dir,
		"name": project_name,
		"project_file": project_file,
		"main_scene": main_scene,
		"features": features
	}


func _get_project_file(path: String) -> Dictionary:
	var abs_dir = _resolve_absolute_dir(path) if not path.is_empty() else ProjectSettings.globalize_path("res://")
	if abs_dir.is_empty():
		return _error("Invalid path: %s" % path)

	var project_file = abs_dir.path_join("project.godot")
	if not FileAccess.file_exists(project_file):
		return _error("project.godot not found in: %s" % abs_dir)

	var file = FileAccess.open(project_file, FileAccess.READ)
	if not file:
		return _error("Failed to open: %s" % project_file)

	var content = file.get_as_text()
	file.close()

	return _success({
		"path": project_file,
		"directory": abs_dir,
		"content": content
	})


func _resolve_absolute_dir(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://"):
		return ProjectSettings.globalize_path(path).simplify_path()
	return path.simplify_path()
