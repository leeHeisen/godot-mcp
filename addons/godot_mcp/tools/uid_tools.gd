@tool
extends "res://addons/godot_mcp/tools/base_tools.gd"

## UID tools for Godot MCP
## Migrated from bradypp/godot-mcp (get_uid / update_project_uids).
##
## Uses the ResourceUID singleton when it is available (Godot 4.4+). The
## singleton API differs between releases:
##   * 4.4  -> get_id_for_path(path) / id_to_text(id) / has_id(id)
##   * 4.5+ -> path_to_uid(path) / uid_to_path(uid) / text_to_id(text)
## Both shapes are detected at runtime. When ResourceUID is missing entirely the
## tools fall back to reading the ".uid" sidecar file and the "uid://..." entry
## in the resource header, so they still report useful information.


func get_tools() -> Array[Dictionary]:
	return [
		{
			"name": "query",
			"description": """UID QUERY: Inspect resource UIDs (Godot 4.4+ feature).

ACTIONS:
- get: Get the UID of a single resource file
- lookup: Resolve a UID (uid://... or decimal id) back to its resource path
- list: List UIDs for the resources inside a directory
- verify: Scan the project and report resources that have no UID

NOTES:
- ResourceUID is a Godot 4.4+ feature. On older builds the tools fall back to
  ".uid" sidecar files and resource headers; if neither exists the resource is
  reported with exists=false instead of raising an error.
- "lookup" also works without ResourceUID by scanning the project for a matching
  UID, at the cost of walking the filesystem.

EXAMPLES:
- Get one UID: {"action": "get", "path": "res://scenes/player.tscn"}
- Resolve a UID: {"action": "lookup", "uid": "uid://b2c3d4e5f6g7h"}
- List UIDs: {"action": "list", "path": "res://scenes", "recursive": true}
- Find missing UIDs: {"action": "verify", "extension": ".tscn"}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["get", "lookup", "list", "verify"],
						"description": "UID query action"
					},
					"path": {
						"type": "string",
						"description": "Resource path or directory (res://)"
					},
					"uid": {
						"type": "string",
						"description": "UID text (uid://...) or decimal integer id"
					},
					"recursive": {
						"type": "boolean",
						"description": "Recurse into subdirectories (default: true)"
					},
					"extension": {
						"type": "string",
						"description": "Extension filter, e.g. .tscn or .tres"
					},
					"include_addons": {
						"type": "boolean",
						"description": "Include the addons/ folder (default: false)"
					},
					"limit": {
						"type": "integer",
						"description": "Maximum number of files to inspect (default: 1000)"
					}
				},
				"required": ["action"]
			}
		},
		{
			"name": "update",
			"description": """UID UPDATE: Re-save resources so their UIDs are (re)generated.

ACTIONS:
- resave_file: Re-save a single resource to regenerate its UID
- resave_project: Re-save every matching resource in the project
- scan_missing: Report which resources still have no UID after a re-save

WORKFLOW:
1. Run {"action": "scan_missing"} to see which resources lack a UID
2. Run {"action": "resave_project"} to regenerate references
3. Run {"action": "scan_missing"} again to confirm

EXAMPLES:
- Re-save one scene: {"action": "resave_file", "path": "res://scenes/player.tscn"}
- Re-save the project: {"action": "resave_project"}
- Custom extensions: {"action": "resave_project", "extensions": [".tscn", ".tres"]}""",
			"inputSchema": {
				"type": "object",
				"properties": {
					"action": {
						"type": "string",
						"enum": ["resave_file", "resave_project", "scan_missing"],
						"description": "UID update action"
					},
					"path": {
						"type": "string",
						"description": "Resource path for resave_file"
					},
					"extensions": {
						"type": "array",
						"items": {"type": "string"},
						"description": "Extensions to re-save (default: [\".tscn\", \".tres\"])"
					},
					"include_addons": {
						"type": "boolean",
						"description": "Include the addons/ folder (default: false)"
					},
					"limit": {
						"type": "integer",
						"description": "Maximum number of files to process (default: 1000)"
					}
				},
				"required": ["action"]
			}
		}
	]


func execute(tool_name: String, args: Dictionary) -> Dictionary:
	match tool_name:
		"query":
			return _execute_query(args)
		"update":
			return _execute_update(args)
		_:
			return _error("Unknown tool: %s" % tool_name)


# ==================== QUERY ====================

func _execute_query(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"get":
			return _uid_get(args.get("path", ""))
		"lookup":
			return _uid_lookup(args.get("uid", ""))
		"list":
			return _uid_list(args)
		"verify":
			return _uid_verify(args)
		_:
			return _error("Unknown action: %s" % action)


func _uid_get(path: String) -> Dictionary:
	if path.is_empty():
		return _error("Path is required")

	path = _to_res_path(path)

	if not FileAccess.file_exists(path):
		return _error("File not found: %s" % path)

	var info = _resolve_uid(path)
	var result = {
		"path": path,
		"absolute_path": ProjectSettings.globalize_path(path),
		"uid": info["uid"],
		"id": info["id"],
		"source": info["source"],
		"exists": not str(info["uid"]).is_empty()
	}

	if not result["exists"]:
		result["message"] = "No UID found. Use uid_update/resave_file to generate one."

	return _success(result)


func _uid_lookup(uid_text: String) -> Dictionary:
	if uid_text.is_empty():
		return _error("UID is required")

	var api = _uid_api()

	if api:
		# Resolve through the numeric id first: has_id() lets an unknown UID fail
		# cleanly, and these three methods exist on both 4.4 and 4.5.
		if api.has_method("text_to_id") and api.has_method("has_id"):
			var id: int = -1
			if uid_text.begins_with("uid://"):
				id = int(api.text_to_id(uid_text))
			elif uid_text.is_valid_int():
				id = int(uid_text)
			else:
				return _error("Invalid UID: %s" % uid_text)

			var known: bool = api.has_id(id)
			var resolved_path := ""
			if known and api.has_method("get_id_path"):
				resolved_path = str(api.get_id_path(id))

			var canonical = str(api.id_to_text(id)) if api.has_method("id_to_text") else uid_text

			return _success({
				"uid": canonical,
				"id": id,
				"path": resolved_path,
				"exists": known
			})

		if api.has_method("uid_to_path"):
			var resolved := str(api.uid_to_path(uid_text))
			return _success({
				"uid": uid_text,
				"id": -1,
				"path": resolved,
				"exists": not resolved.is_empty()
			})

	# No ResourceUID singleton in this build: fall back to scanning the project
	return _lookup_by_scan(uid_text)


func _lookup_by_scan(uid_text: String) -> Dictionary:
	var files: Array = []
	_collect_res_file_paths("res://", true, "", true, 2000, files)

	for file_path in files:
		var info = _resolve_uid(file_path)
		if str(info["uid"]) == uid_text:
			return _success({
				"uid": uid_text,
				"id": info["id"],
				"path": file_path,
				"source": info["source"],
				"exists": true
			})

	return _success({
		"uid": uid_text,
		"id": -1,
		"path": "",
		"exists": false,
		"hint": "Scanned the project and found no resource with this UID.",
		"note": _uid_api_missing_message()
	})


func _uid_list(args: Dictionary) -> Dictionary:
	var dir_path = _to_res_path(args.get("path", "res://"))
	var recursive: bool = args.get("recursive", true)
	var extension: String = args.get("extension", "")
	var include_addons: bool = args.get("include_addons", false)
	var limit: int = int(args.get("limit", 1000))

	if not DirAccess.dir_exists_absolute(dir_path):
		return _error("Directory not found: %s" % dir_path)

	var files: Array = []
	_collect_res_file_paths(dir_path, recursive, extension, include_addons, limit, files)

	var entries: Array[Dictionary] = []
	var with_uid := 0

	for file_path in files:
		var info = _resolve_uid(file_path)
		if not str(info["uid"]).is_empty():
			with_uid += 1
		entries.append({
			"path": file_path,
			"uid": info["uid"],
			"id": info["id"],
			"source": info["source"]
		})

	return _success({
		"directory": dir_path,
		"scanned": entries.size(),
		"with_uid": with_uid,
		"without_uid": entries.size() - with_uid,
		"resources": entries
	})


func _uid_verify(args: Dictionary) -> Dictionary:
	var extension: String = args.get("extension", ".tscn")
	var include_addons: bool = args.get("include_addons", false)
	var limit: int = int(args.get("limit", 1000))

	var files: Array = []
	_collect_res_file_paths("res://", true, extension, include_addons, limit, files)

	var missing: Array[String] = []
	var with_uid := 0

	for file_path in files:
		var info = _resolve_uid(file_path)
		if str(info["uid"]).is_empty():
			missing.append(file_path)
		else:
			with_uid += 1

	var result = {
		"extension": extension,
		"scanned": files.size(),
		"with_uid": with_uid,
		"missing_count": missing.size(),
		"missing": missing
	}

	if not missing.is_empty():
		result["hint"] = "Run uid_update/resave_project to regenerate the missing UIDs."

	return _success(result)


# ==================== UPDATE ====================

func _execute_update(args: Dictionary) -> Dictionary:
	var action = args.get("action", "")

	match action:
		"resave_file":
			return _uid_resave_file(args.get("path", ""))
		"resave_project":
			return _uid_resave_project(args)
		"scan_missing":
			return _uid_verify(args)
		_:
			return _error("Unknown action: %s" % action)


func _uid_resave_file(path: String) -> Dictionary:
	if path.is_empty():
		return _error("Path is required")

	path = _to_res_path(path)

	if not FileAccess.file_exists(path):
		return _error("File not found: %s" % path)

	var before = _resolve_uid(path)

	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not resource:
		return _error("Failed to load resource: %s" % path)

	var error = ResourceSaver.save(resource, path)
	if error != OK:
		return _error("Failed to re-save resource: %s" % error_string(error))

	_ensure_uid_for_path(path)
	_refresh_filesystem()

	var after = _resolve_uid(path)

	return _success({
		"path": path,
		"uid_before": before["uid"],
		"uid_after": after["uid"],
		"id": after["id"],
		"source": after["source"]
	}, "Resource re-saved: %s" % path)


func _uid_resave_project(args: Dictionary) -> Dictionary:
	var raw_extensions = args.get("extensions", [".tscn", ".tres"])
	var include_addons: bool = args.get("include_addons", false)
	var limit: int = int(args.get("limit", 1000))

	var extensions: Array[String] = []
	if raw_extensions is Array:
		for ext in raw_extensions:
			var normalized = str(ext)
			if not normalized.begins_with("."):
				normalized = "." + normalized
			extensions.append(normalized)
	if extensions.is_empty():
		extensions = [".tscn", ".tres"]

	var files: Array = []
	for ext in extensions:
		_collect_res_file_paths("res://", true, ext, include_addons, limit, files)

	var succeeded := 0
	var failed: Array[Dictionary] = []
	var regenerated: Array[String] = []

	for file_path in files:
		var before = _resolve_uid(file_path)
		var resource = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE)

		if not resource:
			failed.append({"path": file_path, "error": "Failed to load resource"})
			continue

		var error = ResourceSaver.save(resource, file_path)
		if error != OK:
			failed.append({"path": file_path, "error": error_string(error)})
			continue

		succeeded += 1

		_ensure_uid_for_path(file_path)

		var after = _resolve_uid(file_path)
		if str(before["uid"]).is_empty() and not str(after["uid"]).is_empty():
			regenerated.append(file_path)

	_refresh_filesystem()

	var result = {
		"extensions": extensions,
		"processed": files.size(),
		"succeeded": succeeded,
		"failed_count": failed.size(),
		"regenerated_count": regenerated.size(),
		"regenerated": regenerated
	}

	if not failed.is_empty():
		result["failed"] = failed

	return _success(result, "Re-saved %d resource(s)" % succeeded)


# ==================== UID helpers ====================

func _uid_api():
	if Engine.has_singleton("ResourceUID"):
		return Engine.get_singleton("ResourceUID")
	return null


func _uid_api_missing_message() -> String:
	return "The ResourceUID singleton is unavailable in this build; falling back to .uid sidecar files and resource headers."


func _resolve_uid(path: String) -> Dictionary:
	var result := {"uid": "", "id": -1, "source": ""}

	var api = _uid_api()
	if api:
		# Godot 4.5+: path_to_uid() returns "uid://..." or the path unchanged
		if api.has_method("path_to_uid"):
			var uid_text = str(api.path_to_uid(path))
			if uid_text.begins_with("uid://"):
				result["uid"] = uid_text
				result["id"] = _id_from_text(api, uid_text)
				result["source"] = "ResourceUID"
				return result
		# Godot 4.4: get_id_for_path() returns INVALID_ID when there is no UID
		elif api.has_method("get_id_for_path"):
			var id: int = api.get_id_for_path(path)
			if id != -1:
				result["id"] = id
				result["uid"] = str(api.id_to_text(id))
				result["source"] = "ResourceUID"
				return result

	var sidecar = _read_text_trimmed(path + ".uid")
	if not sidecar.is_empty():
		result["uid"] = sidecar
		result["source"] = "sidecar"
		return result

	var header = _read_header_uid(path)
	if not header.is_empty():
		result["uid"] = header
		result["source"] = "header"
		return result

	return result


func _id_from_text(api, uid_text: String) -> int:
	if api.has_method("text_to_id"):
		return int(api.text_to_id(uid_text))
	return -1


func _ensure_uid_for_path(path: String) -> void:
	"""Ask ResourceUID to create a UID for the path when that API exists."""
	var api = _uid_api()
	if api and api.has_method("ensure_path"):
		api.ensure_path(path)


func _read_text_trimmed(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return ""

	var content = file.get_as_text()
	file.close()
	return content.strip_edges()


func _read_header_uid(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return ""

	var head = file.get_buffer(1024).get_string_from_utf8()
	file.close()

	var regex = RegEx.new()
	if regex.compile('uid="(uid://[^"]+)"') != OK:
		return ""

	var match_result = regex.search(head)
	if match_result:
		return match_result.get_string(1)

	return ""


func _to_res_path(path: String) -> String:
	if path.is_empty():
		return "res://"
	if path.begins_with("res://") or path.begins_with("user://"):
		return path
	return "res://" + path.trim_prefix("/")


func _collect_res_file_paths(
	dir_path: String,
	recursive: bool,
	extension: String,
	include_addons: bool,
	limit: int,
	results: Array
) -> void:
	if results.size() >= limit:
		return

	var dir = DirAccess.open(dir_path)
	if not dir:
		return

	var wanted = extension.trim_prefix(".").to_lower()

	dir.list_dir_begin()
	var entry = dir.get_next()

	while entry != "" and results.size() < limit:
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		var full_path = dir_path.path_join(entry)

		if dir.current_is_dir():
			var skip_addons = not include_addons and entry == "addons"
			if recursive and not skip_addons:
				_collect_res_file_paths(full_path, recursive, extension, include_addons, limit, results)
		elif wanted.is_empty() or full_path.get_extension().to_lower() == wanted:
			results.append(full_path)

		entry = dir.get_next()

	dir.list_dir_end()


func _refresh_filesystem() -> void:
	var fs = _get_filesystem()
	if fs:
		fs.scan()
