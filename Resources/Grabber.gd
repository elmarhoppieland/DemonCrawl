extends Node
class_name Grabber

# ==============================================================================
static var _main_grabber: Grabber
# ==============================================================================
@export var main := false
@export var enabled := true :
	set(value):
		enabled = value
		
		if not enabled:
			if _mouse_inside:
				_mouse_inside = false
				unhover()
			
			disable()
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
		if enabled:
			_mouse_inside = true
	)
	unhovered.connect(func():
		_mouse_inside = false
	)
	
	interacted.connect(interact)
	hovered.connect(hover)
	unhovered.connect(unhover)
	second_interacted.connect(second_interact)
	
	if main and enabled:
		await get_tree().process_frame
		interacted.emit()
		_main_grabber = self


func _process(_delta: float) -> void:
	if not enabled:
		return
	
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


func disable() -> void:
	pass


static func select_main() -> void:
	if is_instance_valid(_main_grabber):
		_main_grabber.interacted.emit()
