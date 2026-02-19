@tool
extends TextureRect
class_name StageBackground

# ==============================================================================
const FLASH_DURATION_DEFAULT := 0.2
# ==============================================================================
var _flash_timer: SceneTreeTimer
# ==============================================================================

func _enter_tree() -> void:
	_update_theme()
	
	owner.theme_changed.connect(_update_theme)
	await tree_exited
	owner.theme_changed.disconnect(_update_theme)


func _update_theme() -> void:
	texture = owner.get_theme_icon("bg", "StageScene")


func flash_red(duration: float = FLASH_DURATION_DEFAULT) -> void:
	flash(Color.RED, duration)


func flash(color: Color, duration: float = FLASH_DURATION_DEFAULT) -> void:
	set_color(color)
	
	_flash_timer = get_tree().create_timer(duration)
	await _flash_timer.timeout
	_flash_timer = null
	
	reset_color()


func set_color(color: Color) -> void:
	if _flash_timer:
		await _flash_timer.timeout
	material.set_shader_parameter("color_transform_enabled", true)
	material.set_shader_parameter("color_transform", color)


func reset_color() -> void:
	material.set_shader_parameter("color_transform_enabled", false)
