extends Control

const ICON_FOLDER = preload("res://addons/FileSystem After Export By Tiffany/FileSystem/Folder.svg")
const ICON_FILE = preload("res://addons/FileSystem After Export By Tiffany/FileSystem/Script.svg")

@onready var tree: Tree = $CenterContainer/VBoxContainer/HBoxContainer/Tree

var FILES = load("res://addons/FileSystem After Export By Tiffany/FileSystem/file_registry.gd").FILES

func _ready():
	tree.clear()
	var root = tree.create_item()
	build_tree(root, FILES)
	# Allow selection
	tree.set_select_mode(Tree.SELECT_SINGLE)
	# Connect the signal via code if not done in editor
	tree.item_activated.connect(_on_item_selected)
	tree.item_mouse_selected.connect(_detect_mouse_click)

func build_tree(parent: TreeItem, dict: Dictionary):
	for key in dict.keys():
		var value = dict[key]

		var item = tree.create_item(parent)
		item.set_text(0, key)

		if value is Dictionary:
			var metadata = {
				"file_extension": "Folder",
				"value": "n/a"
			}
			item.set_icon(0, ICON_FOLDER)
			item.set_metadata(0, metadata)
			build_tree(item, value) # recursive call
		else:
			var metadata: Dictionary = {
				"file_extension": value.resource_path.get_extension(),
				"value": value
			}
			item.set_tooltip_text(0, "(."+ value.resource_path.get_extension()+ " File)")
			item.set_icon(0, ICON_FILE)
			item.set_metadata(0, metadata) # store file resource


func _on_item_selected():
	# Get the clicked/selected item
	var item = tree.get_selected()
	if item:
		print("Selected: ", item.get_text(0)) # Column 0 tetexture
		print(item.get_metadata(0)["value"].resource_path)
		print(item.get_metadata(0)["file_extension"])
		if item.get_metadata(0)["file_extension"] == "gd":
			var path = item.get_metadata(0)["value"].resource_path
			var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
			$CenterContainer/VBoxContainer/HBoxContainer/RichTextLabel.text = file_access.get_as_text()
		if item.get_metadata(0)["file_extension"] == "svg":
			var path = item.get_metadata(0)["value"]
			$CenterContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = path


func _detect_mouse_click(mouse_position: Vector2, mouse_button_index: int):
	if mouse_button_index == 2:
		_on_item_selected()
