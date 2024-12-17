@tool
extends TextureRect
class_name CellTextureRect

# ==============================================================================
var _mode := Cell.Mode.HIDDEN
# ==============================================================================

func _ready() -> void:
	_mode = owner.get_mode()
	theme_changed.connect(_update)
	owner.mode_changed.connect(func(mode: Cell.Mode) -> void:
		_mode = mode
		_update()
	)
	_update()


func _update() -> void:
	match _mode:
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
