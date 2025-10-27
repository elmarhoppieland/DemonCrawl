@tool
extends MarginContainer
class_name StageIcon

## An icon on the [StagesOverview] for a single stage.

# ==============================================================================
const IMAGE_PATH := "res://assets/skins/%s/bg.png"
const DARKEN_AMOUNT := 0.5
# ==============================================================================
@export var stage: StageBase :
	set(value):
		stage = value
		
		_update()
		
		if value and not value.changed.is_connected(_update):
			value.changed.connect(_update)
# ==============================================================================
var show_icon := false :
	set(value):
		show_icon = value
		
		if not is_node_ready():
			await ready
		
		_shadow.visible = value
		_icon.visible = value

var _hovered := false
# ==============================================================================
@onready var _icon: TextureRect = %Icon
@onready var _shadow: TextureRect = %Shadow
@onready var _lock: TextureRect = %Lock
@onready var _checkmark: TextureRect = %Checkmark
# ==============================================================================
signal selected()
# ==============================================================================

func _process(_delta: float) -> void:
	if _hovered and Input.is_action_just_pressed("interact"):
		select()


func select(instant_focus: bool = false) -> void:
	selected.emit()
	Focus.move_to(self, instant_focus)


func _update() -> void:
	if not is_node_ready():
		await ready
	
	if not stage:
		return
	
	_lock.visible = stage.locked
	_checkmark.visible = stage.completed
	if stage.locked or stage.completed:
		_icon.modulate = Color.WHITE.darkened(DARKEN_AMOUNT)
	else:
		_icon.modulate = Color.WHITE
	
	_icon.texture = stage.get_small_icon()


func _on_mouse_entered() -> void:
	_hovered = true


func _on_mouse_exited() -> void:
	_hovered = false
