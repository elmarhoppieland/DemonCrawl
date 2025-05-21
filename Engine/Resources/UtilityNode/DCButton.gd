@tool
extends BaseButton
#class_name DCButton

# ==============================================================================
enum Type {
	GENERAL,
	CONFIRM,
	CANCEL,
}
# ==============================================================================
@export var type := Type.GENERAL :
	set(value):
		type = value
		reload_theme()
@export_multiline var text := "" :
	set(value):
		text = value
		label.text = value
		reset_size.call_deferred()
@export var animation_duration := 0.2
# ==============================================================================
var label := Label.new()
var outline := NinePatchRect.new()
var inside := ColorRect.new()
var tween: Tween
# ==============================================================================

func _enter_tree() -> void:
	reload_theme()
	
	if not label.get_parent():
		label.text = text
		label.label_settings = LabelSettings.new()
		label.label_settings.font_size = get_theme_font_size("font_size", "Label")
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.set_anchors_and_offsets_preset.call_deferred(Control.PRESET_CENTER)
		add_child(label)
	
	if not outline.get_parent():
		outline.texture = preload("res://Assets/sprites/button.png")
		outline.draw_center = false
		for i in 4:
			outline.set_patch_margin(i, 1)
		outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(outline)
	
	if not inside.get_parent():
		inside.modulate.a = 0
		inside.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 1)
		inside.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(inside)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _exit_tree() -> void:
	mouse_entered.disconnect(_on_mouse_entered)
	mouse_exited.disconnect(_on_mouse_exited)


func _get_minimum_size() -> Vector2:
	return label.size + Vector2(6, 4)


## Reloads and applies the colors specified in the [DCButton]'s theme.
func reload_theme() -> void:
	match type:
		Type.GENERAL:
			modulate = get_theme_color("general", "DCButton")
		Type.CONFIRM:
			modulate = get_theme_color("confirm", "DCButton")
		Type.CANCEL:
			modulate = get_theme_color("cancel", "DCButton")


func _on_mouse_entered() -> void:
	if not Engine.is_editor_hint():
		tween = create_tween()
		tween.tween_property(inside, "modulate:a", 1.0, animation_duration)
		await tween.finished
		tween = null


func _on_mouse_exited() -> void:
	if tween:
		tween.kill()
		tween = null
	
	inside.modulate.a = 0
