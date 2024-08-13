@tool
extends TextureRect
class_name FlagCellTexture

# ==============================================================================

func _ready() -> void:
	_update_texture()
	_update_visibility()
	
	theme_changed.connect(_update_texture)
	owner.state_changed.connect(_update_visibility.unbind(1))


func play_flag() -> void:
	const FLAG_ANIM_DURATION := 0.1
	
	show()
	
	if not is_inside_tree():
		await tree_entered
	
	create_tween().tween_property(get_parent(), "scale", Vector2.ONE, FLAG_ANIM_DURATION).from(Vector2.ZERO)


func _update_visibility() -> void:
	visible = owner.state == Cell.State.FLAGGED


func _update_texture() -> void:
	texture = owner.get_theme_icon("flag", "Cell")
