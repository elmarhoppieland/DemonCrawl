@tool
extends MarginContainer
class_name __IconManagerIconEditor

# ==============================================================================
@export var icon_name := "" :
	set(value):
		icon_name = value
		
		if not is_node_ready():
			await ready
		
		name_edit.text = value
	get:
		if not name_edit:
			return icon_name
		return name_edit.text
@export var atlas: Texture2D :
	set(value):
		atlas = value
		
		if not is_node_ready():
			await ready
		
		texture_rect.texture.atlas = atlas
@export var region := Rect2() :
	set(value):
		region = value
		
		if not is_node_ready():
			await ready
		
		_update_region()
		
		region_edits[0].value = value.position.x
		region_edits[1].value = value.position.y
		region_edits[2].value = value.size.x
		region_edits[3].value = value.size.y
	get:
		if region_edits.is_empty():
			return region
		return Rect2(
			region_edits[0].value, region_edits[1].value, region_edits[2].value, region_edits[3].value
		)
# ==============================================================================
@onready var name_edit: LineEdit = %NameEdit
@onready var texture_rect: TextureRect = %TextureRect
@onready var region_edits: Array[LineEdit] = [
	%IntegerEdit, %IntegerEdit2, %IntegerEdit3, %IntegerEdit4
]
# ==============================================================================
signal name_changed(new_name: String)
signal region_changed(new_region: Rect2)
signal deleted()
# ==============================================================================

func _update_region() -> void:
	if not is_node_ready():
		await ready
	
	texture_rect.texture.region = region


func _on_integer_edit_value_changed(_new_value: int) -> void:
	_update_region()
	
	region_changed.emit(region)


func _on_name_edit_text_changed(new_text: String) -> void:
	name_changed.emit(new_text)


func _on_name_edit_text_submitted(_new_text: String) -> void:
	name_edit.release_focus()


func _on_delete_button_pressed() -> void:
	deleted.emit()
