@tool
extends MarginContainer
class_name FadeButton

# ==============================================================================
@export var animation_duration := 0.1

@export var press_action := &"interact"
@export var shortcut_action := &""

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

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"press_action", &"shortcut_action":
			var inputs := ProjectSettings.get_property_list().map(func(prop: Dictionary) -> String:
				return prop.name
			).filter(func(prop: String) -> bool:
				return prop.begins_with("input/") and ProjectSettings.has_setting(prop)
			).map(func(prop: String) -> String:
				return prop.trim_prefix("input/")
			)
			property.hint = PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = ",".join(inputs)
		&"animation_duration":
			property.hint_string = "suffix:sec"


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
	if Engine.is_editor_hint():
		return
	
	if _is_pressed():
		pressed.emit()


func _is_pressed() -> bool:
	if InputMap.has_action(shortcut_action) and Input.is_action_just_pressed(shortcut_action):
		return true
	
	return InputMap.has_action(press_action) and mouse_is_inside and Input.is_action_just_pressed(press_action)
