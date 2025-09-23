@tool
extends Control
class_name Toast

# ==============================================================================
@export var icon: Texture2D :
	set(value):
		icon = value
		if not is_node_ready():
			await ready
		icon_rect.texture = value
		base_container.reset_size()
	get:
		if not icon_rect:
			return icon
		return icon_rect.texture
@export_multiline var text := "" :
	set(value):
		text = value
		if not is_node_ready():
			await ready
		label.text = value
		base_container.reset_size()
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
signal finished()
# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		visibility_changed.connect(func() -> void:
			if visible:
				await play()
				hide()
		)
		return
	
	play()


func play() -> void:
	const SLIDE_DURATION := 0.4
	const TOAST_DURATION := 2.0
	
	show()
	
	base_container.reset_size()
	
	await Promise.defer()
	
	#modulate.a = 0
	#await get_tree().process_frame
	#modulate.a = 1
	
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Node2D, "position:x", 0.0, SLIDE_DURATION).from(-base_container.size.x).set_ease(Tween.EASE_OUT)
	tween.tween_interval(TOAST_DURATION)
	tween.tween_property($Node2D, "position:x", -size.x, SLIDE_DURATION).set_ease(Tween.EASE_IN)
	
	await tween.finished
	finished.emit()


static func create(_text: String = "", _icon: Texture2D = null) -> Toast:
	var toast: Toast = load("res://engine/resources/singletons/toast.tscn").instantiate()
	toast.text = _text
	toast.icon = _icon
	return toast


func _on_margin_container_resized() -> void:
	if not is_node_ready():
		await ready
	custom_minimum_size = base_container.size


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		return Vector2.ZERO
	return base_container.size
