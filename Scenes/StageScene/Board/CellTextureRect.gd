@tool
extends TextureRect
class_name CellTextureRect

# ==============================================================================

func _ready() -> void:
	theme_changed.connect(_update)
	get_cell().changed.connect(_update)
	_update()


func _update() -> void:
	match get_cell().get_mode():
		Cell.Mode.HIDDEN:
			texture = get_theme_icon("hidden", "Cell")
		Cell.Mode.VISIBLE:
			texture = get_theme_icon("bg", "Cell")
		Cell.Mode.FLAGGED:
			texture = get_theme_icon("flag_bg", "Cell")
		Cell.Mode.CHECKING:
			texture = get_theme_icon("checking", "Cell")


func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage |= PROPERTY_USAGE_READ_ONLY


func get_cell() -> Cell:
	return owner
