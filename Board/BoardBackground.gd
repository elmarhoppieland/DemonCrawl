@tool
extends TextureRect
class_name BoardBackground

# ==============================================================================
const FLASH_DURATION_DEFAULT := 0.2
# ==============================================================================
static var _instance: BoardBackground
# ==============================================================================

func _init() -> void:
	_instance = self


func _ready() -> void:
	await get_tree().process_frame
	
	texture = owner.get_theme_icon("board_bg", "Board")
	
	owner.theme_changed.connect(func(): texture = owner.get_theme_icon("board_bg", "Board"))


static func flash_red(duration: float = FLASH_DURATION_DEFAULT) -> void:
	flash(Color.RED, duration)


static func flash(color: Color, duration: float = FLASH_DURATION_DEFAULT) -> void:
	_instance.material.set_shader_parameter("color_transform_enabled", true)
	_instance.material.set_shader_parameter("color_transform", color)
	
	await _instance.get_tree().create_timer(duration).timeout
	
	_instance.material.set_shader_parameter("color_transform_enabled", false)
