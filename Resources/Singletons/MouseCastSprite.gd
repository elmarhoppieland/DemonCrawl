extends CanvasLayer
class_name MouseCastSprite

# ==============================================================================
@onready var anchor: Node2D = %Anchor
@onready var foreground: Sprite2D = %Foreground
# ==============================================================================
signal cast_finished()
# ==============================================================================

func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if visible:
		anchor.position = anchor.get_global_mouse_position()
		
		if Input.is_action_just_pressed("interact"):
			cast_finished.emit()
		elif Input.is_action_just_pressed("secondary_interact"):
			cast_finished.emit()


func cast(item: Item) -> void:
	foreground.texture.item = item
	show()
	anchor.position = anchor.get_global_mouse_position()
	
	GuiLayer.get_statbar().inventory_toggle()
	
	await cast_finished
	
	hide()


func get_position() -> Vector2:
	return foreground.global_position
