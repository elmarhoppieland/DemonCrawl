@tool
extends MarginContainer
class_name MainMenuButton

# ==============================================================================
@export var texture: Texture2D :
	set(value):
		texture = value
		if not sprite:
			await ready
		sprite.texture = value
		if value:
			sprite.position.x = (size.x - value.get_width()) / 2
@export var text := ""
@export var color := Color.BLACK
# ==============================================================================
var mouse_is_inside := false
# ==============================================================================
@onready var sprite: Sprite2D = %Sprite2D :
	set(value):
		sprite = value
		sprite.position.x = (size.x - texture.get_width()) / 2
# ==============================================================================
signal pressed()
# ==============================================================================

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	const ANIM_DURATION := 0.4
	mouse_entered.connect(func():
		var tween := create_tween().set_parallel()
		tween.tween_property(%ColorRect, "custom_minimum_size:x", 16.0, ANIM_DURATION / 2)
		tween.tween_property(sprite, "position:y", -3.0, ANIM_DURATION)
		tween.tween_property(sprite, "modulate:a", 1.0, ANIM_DURATION)
		
		mouse_is_inside = true
	)
	mouse_exited.connect(func():
		var tween := create_tween().set_parallel()
		tween.tween_property(%ColorRect, "custom_minimum_size:x", 0.0, ANIM_DURATION / 2)
		tween.tween_property(sprite, "position:y", 1.0, ANIM_DURATION)
		tween.tween_property(sprite, "modulate:a", 0.7, ANIM_DURATION)
		
		mouse_is_inside = false
	)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if mouse_is_inside and Input.is_action_just_pressed("interact"):
		pressed.emit()
