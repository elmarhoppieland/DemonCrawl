extends Control
class_name Toast

# ==============================================================================
@export var icon: Texture2D :
	set(value):
		icon = value
		if not icon_rect:
			await ready
		icon_rect.texture = icon
	get:
		if not icon_rect:
			return icon
		return icon_rect.texture
@export_multiline var text := "" :
	set(value):
		text = value
		if not label:
			await ready
		label.text = value
	get:
		if not label:
			return text
		return label.text
# ==============================================================================
@onready var base_container: MarginContainer = %BaseContainer
@onready var color_rect: ColorRect = %ColorRect
@onready var icon_rect: TextureRect = %IconRect
@onready var label: Label = %Label
# ==============================================================================

func _ready() -> void:
	const SLIDE_DURATION := 0.4
	const TOAST_DURATION := 2.0
	
	if TOAST_DURATION < 0.1:
		queue_free()
		return
	
	modulate.a = 0
	await get_tree().process_frame
	modulate.a = 1
	
	var tween := create_tween()
	tween.tween_property($Node2D, "position:x", 0.0, SLIDE_DURATION).from(-size.x)
	tween.tween_interval(TOAST_DURATION)
	tween.tween_property($Node2D, "position:x", -size.x, SLIDE_DURATION)
	
	await tween.finished
	queue_free()


static func create(_text: String = "", _icon: Texture2D = null) -> Toast:
	var toast: Toast = ResourceLoader.load("res://Scenes/Singletons/Toast.tscn").instantiate()
	toast.text = _text
	toast.icon = _icon
	return toast


func _on_margin_container_resized() -> void:
	if not base_container:
		await ready
	custom_minimum_size = base_container.size
