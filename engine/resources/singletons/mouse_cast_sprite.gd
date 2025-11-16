extends CanvasLayer
class_name MouseCastSprite

# ==============================================================================
@onready var anchor: Node2D = %Anchor
@onready var foreground: TextureRect = %Foreground
# ==============================================================================
signal cast_finished()
signal cast_cancelled()
# ==============================================================================

func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if visible:
		anchor.position = anchor.get_global_mouse_position()
		
		if Input.is_action_just_pressed("interact"):
			cast_finished.emit()
		elif Input.is_action_just_pressed("secondary_interact"):
			cast_cancelled.emit()


func cast(icon: Texture2D) -> bool:
	foreground.texture = icon
	show.call_deferred()
	anchor.position = anchor.get_global_mouse_position()
	
	if GuiLayer.get_statbar().is_inventory_open():
		GuiLayer.get_statbar().inventory_toggle()
	
	var r: bool = await Promise.new({ cast_finished: true, cast_cancelled: false }).any()
	
	hide()
	
	return r


func get_position() -> Vector2:
	return foreground.global_position
