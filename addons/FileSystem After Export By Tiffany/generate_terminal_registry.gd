@tool
extends EditorScript
const FILE_OUTPUT_PATH := "res://addons/FileSystem After Export By Tiffany/FileSystem/file_registry.gd"

const VALID_EXTENSIONS := [
	"tscn",
	"tres",
	"res",
	"gd",
	"png",
	"ogg",
	"wav",
	"mp3",
	"ttf",
	"svg",
	"ogv",
]

var directories: Array = []
var files: Array = []
var file_names = []


func _run():
	DirAccess.make_dir_recursive_absolute("res://addons/FileSystem After Export By Tiffany/FileSystem")
	recursive_dict()

func write(lines, path):
	var gun = FileAccess.open(path, FileAccess.WRITE)
	if gun == null:
		push_error("Failed to open output file: " + path)
		return
	gun.store_string("\n".join(lines))
	gun.close()

func recursive_dict():
	var tree = scan_directory("res://", true)

	write_dictionary_as_gd(
		"FILES",
		tree,
		FILE_OUTPUT_PATH
	)

var no_go = ["res://addons/FileSystem After Export By Tiffany/plugin.gd","res://addons/FileSystem After Export By Tiffany/generate_terminal_registry.gd","res://addons/GodotTerminalButByTiffany",]

func scan_directory(path: String, include_extension := false) -> Dictionary:
	var result := {}
	
	if no_go.has(path):
		return result
	var dir := DirAccess.open(path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var name := dir.get_next()

	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full_path
		if path == "res://":
			full_path = path + name
		else:
			full_path = path + "/" + name

		if dir.current_is_dir():
			# Folder → nested dictionary
			if !no_go.has(full_path):
				result[name] = scan_directory(full_path, include_extension)
			else:
				print(full_path)
		else:
			if !no_go.has(full_path):
				var ext := name.get_extension()
				if VALID_EXTENSIONS.has(ext):
					var key := name.get_basename()
					
					if include_extension:
						key += "." + ext
					if !full_path == FILE_OUTPUT_PATH:
						result[key] = full_path
			else:
				print(full_path)
		name = dir.get_next()

	dir.list_dir_end()
	return result

func write_dictionary_as_gd(name: String, dict: Dictionary, path: String):
	var lines := []
	lines.append("const %s := %s" % [name, _dict_to_string(dict, 0)])

	write(lines, path)

func _dict_to_string(dict: Dictionary, indent := 0) -> String:
	var tabs := "\t".repeat(indent)
	var inner := []

	var keys := dict.keys()
	keys.sort()

	for key in keys:
		var value = dict[key]

		if value is Dictionary:
			inner.append('%s"%s": %s' % [
				tabs + "\t",
				key,
				_dict_to_string(value, indent + 1)
			])
		elif value is String:
			inner.append('%s"%s": preload("%s")' % [
				tabs + "\t",
				key,
				value
			])
		else:
			push_error(
				"Invalid value type in registry: %s (%s)" %
				[value, typeof(value)]
			)

	return "{\n%s\n%s}" % [
		",\n".join(inner),
		tabs
	]
