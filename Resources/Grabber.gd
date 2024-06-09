extends Node
class_name Grabber

# ==============================================================================
@export var main := false
# ==============================================================================
var _mouse_inside := false
# ==============================================================================
@onready var control: Control = get_parent()
@onready var hovered := control.mouse_entered
@onready var unhovered := control.mouse_exited
# ==============================================================================
signal interacted()
signal second_interacted()
# ==============================================================================

func _init(_main: bool = false) -> void:
	main = _main


func _ready() -> void:
	hovered.connect(func():
		_mouse_inside = true
	)
	unhovered.connect(func():
		_mouse_inside = false
	)
	
	interacted.connect(interact)
	hovered.connect(hover)
	unhovered.connect(unhover)
	second_interacted.connect(second_interact)
	
	if main:
		await get_tree().process_frame
		interacted.emit()


func _process(_delta: float) -> void:
	if _mouse_inside and Input.is_action_just_pressed("interact"):
		interacted.emit()
	if _mouse_inside and Input.is_action_just_pressed("secondary_interact"):
		second_interacted.emit()


func interact() -> void:
	pass


func second_interact() -> void:
	pass


func hover() -> void:
	pass


func unhover() -> void:
	pass
