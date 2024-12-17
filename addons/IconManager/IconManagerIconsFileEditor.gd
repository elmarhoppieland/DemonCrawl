@tool
extends MarginContainer
class_name __IconManagerIconsFileEditor

# ==============================================================================
@export var atlas: Texture2D :
	set(value):
		atlas = value
		
		if not is_node_ready():
			await ready
		
		atlas_texture_rect.texture = atlas
		path_label.text = "(" + atlas.resource_path + ")"
@export var atlas_name := "" :
	set(value):
		atlas_name = value
		
		if not is_node_ready():
			await ready
		
		name_edit.text = value
	get:
		if not is_instance_valid(name_edit):
			return atlas_name
		return name_edit.text
# ==============================================================================
var atlas_data: Array[Dictionary] = []
# ==============================================================================
@onready var icon_editors_container: HFlowContainer = %IconEditorsContainer
@onready var atlas_texture_rect: TextureRect = %AtlasTextureRect
@onready var content_container: HBoxContainer = %ContentContainer
@onready var collapse_button: Button = %CollapseButton
@onready var name_edit: LineEdit = %NameEdit
@onready var path_label: Label = %PathLabel
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog
# ==============================================================================
signal name_changed(new_name: String)
signal data_changed(new_data: Array[Dictionary])
signal deleted()
# ==============================================================================

func _ready() -> void:
	content_container.hide()


func load_data(atlas_id: String, path: String, data: Array[Dictionary]) -> void:
	atlas_name = atlas_id
	atlas = load(path)
	
	atlas_data = data
	
	if not is_node_ready():
		await ready
	
	for child in icon_editors_container.get_children():
		if child is __IconManagerIconEditor:
			icon_editors_container.remove_child(child)
			child.queue_free()
	
	for i in atlas_data.size():
		var icon_data := atlas_data[i]
		
		const ICON_MANAGER_ICON_EDITOR := preload("res://addons/IconManager/IconManagerIconEditor.tscn")
		
		var editor := ICON_MANAGER_ICON_EDITOR.instantiate() as __IconManagerIconEditor
		editor.atlas = atlas
		editor.region = Rect2(icon_data.x, icon_data.y, icon_data.w, icon_data.h)
		editor.icon_name = icon_data.name
		icon_editors_container.add_child(editor)
		icon_editors_container.move_child(editor, -2)
		
		editor.name_changed.connect(func(new_name: String) -> void:
			icon_data.name = new_name
			data_changed.emit(atlas_data)
		)
		editor.region_changed.connect(func(new_region: Rect2) -> void:
			icon_data.x = new_region.position.x
			icon_data.y = new_region.position.y
			icon_data.w = new_region.size.x
			icon_data.h = new_region.size.y
			data_changed.emit(atlas_data)
		)
		editor.deleted.connect(func() -> void:
			atlas_data.erase(icon_data)
			editor.queue_free()
			data_changed.emit(atlas_data)
		)


func _on_collapse_button_pressed() -> void:
	if content_container.visible:
		collapse_button.icon = preload("res://addons/IconManager/arrow_collapsed.png")
	else:
		collapse_button.icon = preload("res://addons/IconManager/arrow_open.png")
	
	content_container.visible = not content_container.visible


func _on_add_icon_button_pressed() -> void:
	const ICON_MANAGER_ICON_EDITOR := preload("res://addons/IconManager/IconManagerIconEditor.tscn")
	
	var editor := ICON_MANAGER_ICON_EDITOR.instantiate() as __IconManagerIconEditor
	editor.atlas = atlas
	editor.icon_name = "New Icon"
	icon_editors_container.add_child(editor)
	icon_editors_container.move_child(editor, -2)
	
	var icon_data := {
		"name": editor.icon_name,
		"x": 0.0,
		"y": 0.0,
		"w": 0.0,
		"h": 0.0
	}
	atlas_data.append(icon_data)
	data_changed.emit(atlas_data)
	
	editor.name_changed.connect(func(new_name: String) -> void:
		icon_data.name = new_name
		data_changed.emit(atlas_data)
	)
	editor.region_changed.connect(func(new_region: Rect2) -> void:
		icon_data.x = new_region.position.x
		icon_data.y = new_region.position.y
		icon_data.w = new_region.size.x
		icon_data.h = new_region.size.y
		data_changed.emit(atlas_data)
	)
	editor.deleted.connect(func() -> void:
		atlas_data.erase(icon_data)
		editor.queue_free()
		data_changed.emit(atlas_data)
	)


func _on_delete_button_pressed() -> void:
	confirmation_dialog.get_child(0).text = "Are you sure you want to delete '%s'?" % atlas.resource_path.get_file()
	confirmation_dialog.popup_centered()


func _on_confirmation_dialog_confirmed() -> void:
	deleted.emit()


func _on_name_edit_text_changed(new_text: String) -> void:
	name_changed.emit(new_text)


func _on_name_edit_text_submitted(_new_text: String) -> void:
	name_edit.release_focus()
