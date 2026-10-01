@tool
extends RefCounted
class_name MCPReadOnlyPolicy

## Read-only policy for the Godot MCP Server.
## Migrated from bradypp/godot-mcp READ_ONLY_MODE.
##
## POLICY maps a full tool name ("<category>_<tool>") to the list of actions
## that are safe to run while read-only mode is enabled. A single "*" entry
## means every action of that tool is safe.
##
## The policy is an allow-list, so anything not listed here is denied while
## read-only mode is active. Read-only means "does not modify project files,
## resources, scenes, nodes or project settings"; launching a process or
## changing editor view state is still allowed, matching bradypp behaviour.

const POLICY: Dictionary = {
	# --- animation (inspection only) ---
	"animation_player": ["list", "get_current"],
	"animation_animation": ["get_info"],
	"animation_track": ["list"],
	"animation_tween": ["info"],
	"animation_animation_tree": ["get", "get_parameters"],
	"animation_state_machine": ["list_states", "list_transitions", "get_current"],
	"animation_blend_space": ["get_points"],
	"animation_blend_tree": ["list_nodes"],

	# --- audio (inspection only) ---
	"audio_bus": ["list", "get_info", "get_effect"],
	"audio_player": ["list", "get_info"],

	# --- debug (inspection only) ---
	"debug_performance": ["*"],
	"debug_profiler": ["is_active"],
	"debug_class_db": ["*"],
	"debug_output": ["*"],

	# --- editor (view state / external launch) ---
	"editor_status": ["get_info", "get_main_screen", "get_distraction_free"],
	"editor_settings": ["get", "list_category"],
	"editor_undo_redo": ["get_info"],
	"editor_inspector": ["get_edited", "get_selected_property", "inspect_resource"],
	"editor_filesystem": ["get_selected", "get_current_path"],
	"editor_plugin": ["list", "is_enabled"],
	"editor_launch": ["*"],

	# --- filesystem (reads only) ---
	"filesystem_directory": ["list", "exists", "get_files"],
	"filesystem_file": ["read", "exists", "get_info"],
	"filesystem_json": ["read", "get_value"],
	"filesystem_search": ["find_files", "grep"],

	# --- geometry (inspection only) ---
	"geometry_csg": ["get_info", "list"],
	"geometry_gridmap": [
		"get_info", "get_cell", "get_used_cells", "get_used_cells_by_item", "get_meshes"
	],
	"geometry_multimesh": ["get_info"],

	# --- group (inspection only) ---
	"group_group": ["list", "is_in", "get_nodes"],

	# --- lighting (inspection only) ---
	"lighting_light": ["get_info", "list"],
	"lighting_environment": ["get_info"],
	"lighting_sky": ["get_info"],

	# --- material (inspection only) ---
	"material_material": ["get_info", "get_property", "list_properties"],
	"material_mesh": ["get_info", "list_surfaces", "get_surface_material", "get_aabb"],

	# --- navigation (inspection only) ---
	"navigation_navigation": [
		"get_map_info", "list_regions", "list_agents", "get_path", "get_agent_info"
	],

	# --- node (inspection only) ---
	"node_query": ["*"],
	"node_transform": ["get_transform"],
	"node_property": ["get", "list"],
	"node_hierarchy": ["get_owner"],
	"node_signal": ["list", "has", "get_connections", "get_incoming", "is_connected"],
	"node_group": ["list", "is_in", "get_nodes", "get_first", "count"],
	"node_process": ["get_status"],
	"node_metadata": ["get", "has", "list"],
	"node_call": ["has_method", "get_method_list"],
	"node_visibility": ["is_visible"],
	"node_physics": ["get_collision_info"],

	# --- particle (inspection only) ---
	"particle_particles": ["get_info"],
	"particle_particle_material": ["get_info"],

	# --- physics (inspection / queries) ---
	"physics_physics_body": ["get_info"],
	"physics_collision_shape": ["get_info"],
	"physics_physics_joint": ["get_info", "get_param"],
	"physics_physics_query": ["*"],

	# --- project (inspection only) ---
	"project_info": ["*"],
	"project_discovery": ["*"],
	"project_settings": ["list_category"],
	"project_input": ["list_actions", "get_action"],
	"project_autoload": ["list"],

	# --- resource (inspection only) ---
	"resource_query": ["*"],
	"resource_texture": ["get_info", "list_all"],

	# --- scene (inspection / running the game) ---
	"scene_management": ["get_current"],
	"scene_hierarchy": ["get_tree", "get_selected"],
	"scene_run": ["*"],

	# --- script (inspection only) ---
	"script_manage": ["read", "get_info"],
	"script_attach": ["get_attached"],
	"script_edit": ["get_functions", "get_variables"],
	"script_open": ["get_open_scripts"],

	# --- shader (inspection only) ---
	"shader_shader": ["read", "get_info", "get_uniforms"],
	"shader_shader_material": ["get_info", "get_param", "list_params"],

	# --- signal (inspection only) ---
	"signal_signal": [
		"list", "get_info", "list_connections", "is_connected", "list_all_connections"
	],

	# --- tilemap (inspection only) ---
	"tilemap_tileset": ["*"],
	"tilemap_tilemap": ["get_info", "get_cell", "get_used_cells", "get_used_rect"],

	# --- ui (inspection only) ---
	"ui_theme": ["get_info", "get_color", "get_constant"],
	"ui_control": ["get_layout"],

	# --- uid (inspection only; uid_update writes, so it is not listed) ---
	"uid_query": ["*"]
}


static func is_tool_allowed(tool_name: String) -> bool:
	return POLICY.has(tool_name)


static func allowed_actions(tool_name: String) -> Array:
	if POLICY.has(tool_name):
		return POLICY[tool_name]
	return []


static func is_action_allowed(tool_name: String, action) -> bool:
	if not POLICY.has(tool_name):
		return false

	var allowed: Array = POLICY[tool_name]
	if "*" in allowed:
		return true

	if action == null:
		return false

	return str(action) in allowed


static func allowed_tool_count() -> int:
	return POLICY.size()
