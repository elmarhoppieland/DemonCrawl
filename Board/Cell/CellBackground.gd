@tool
extends TextureRect
class_name CellBackground

# ==============================================================================
enum State {
	HIDDEN,
	CHECKING,
	FLAG,
	OPEN
}
# ==============================================================================
@export var state := State.OPEN :
	set(value):
		state = value
		_update()
# ==============================================================================

func _ready() -> void:
	_update()
	
	theme_changed.connect(_update)


func set_hidden() -> void:
	state = State.HIDDEN


func set_checking() -> void:
	state = State.CHECKING


func set_flag() -> void:
	state = State.FLAG


func set_open() -> void:
	state = State.OPEN


func get_theme_name() -> String:
	match state:
		State.HIDDEN:
			return "hidden"
		State.CHECKING:
			return "checking"
		State.FLAG:
			return "flag_bg"
		State.OPEN:
			return "background"
	
	assert(false, "Invalid state %s." % state)
	return ""


func _update() -> void:
	texture = get_theme_icon(get_theme_name(), "Cell")
