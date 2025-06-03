@tool
extends MarginContainer
class_name FadeButton

# ==============================================================================
@export var animation_duration := 0.1

@export_group("Textures", "texture_")
@export var texture_normal: Texture2D = null :
	set(value):
		texture_normal = value
		normal_texture_rect.texture = value
@export var texture_hover: Texture2D = null :
	set(value):
		texture_hover = value
		hover_texture_rect.texture = value
# ==============================================================================
var mouse_is_inside := false

var normal_texture_rect := TextureRect.new()
var hover_texture_rect := TextureRect.new()
# ==============================================================================
signal pressed()
# ==============================================================================

func _ready() -> void:
	add_child(normal_texture_rect)
	add_child(hover_texture_rect)
	
	hover_texture_rect.modulate.a = 0
	
	mouse_entered.connect(func() -> void:
		create_tween().tween_property(hover_texture_rect, "modulate:a", 1.0, animation_duration)
		mouse_is_inside = true
	)
	mouse_exited.connect(func() -> void:
		create_tween().tween_property(hover_texture_rect, "modulate:a", 0.0, animation_duration)
		mouse_is_inside = false
	)


func _process(_delta: float) -> void:
	if (mouse_is_inside and Input.is_action_just_pressed("interact")) or Input.is_action_just_pressed("back"):
		pressed.emit()
