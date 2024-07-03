extends CanvasLayer
class_name MouseCastSprite

# ==============================================================================
static var _instance: MouseCastSprite
# ==============================================================================
var _board_was_frozen := false
var _board_was_mutable := true
# ==============================================================================
@onready var anchor: Node2D = %Anchor
@onready var foreground: Sprite2D = %Foreground
# ==============================================================================
signal cast_finished()
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _ready() -> void:
	visibility_changed.connect(func():
		if visible:
			_board_was_frozen = Board.frozen
			_board_was_mutable = Board.mutable
			
			Board.frozen = true
			Board.mutable = false
		else:
			Board.frozen = _board_was_frozen
			Board.mutable = _board_was_mutable
	, CONNECT_DEFERRED)
	
	hide()


func _process(_delta: float) -> void:
	if visible:
		anchor.position = anchor.get_global_mouse_position()
		
		if Input.is_action_just_pressed("interact"):
			cast_finished.emit()
		elif Input.is_action_just_pressed("secondary_interact"):
			cast_finished.emit()


static func cast(item: Item) -> void:
	_instance.foreground.texture.item = item
	_instance.show()
	_instance.anchor.position = _instance.anchor.get_global_mouse_position()
	
	Statbar.inventory_toggle()
	
	await _instance.cast_finished
	
	_instance.hide()
