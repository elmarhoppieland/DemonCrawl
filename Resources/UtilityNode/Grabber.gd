extends Node
class_name Grabber

# ==============================================================================
static var _main_grabber: Grabber
# ==============================================================================
## Whether this is the main grabber. The main grabber will be considered interacted
## when it enters the tree (and [signal interacted] is emitted).
## [br][br][b]Note:[/b] Only set this to [code]true[/code] on one grabber per scene.
## If multiple grabbers are main, unexpected behaviour may occur.
@export var main := false
@export var enabled := true : ## Whether this grabber is enabled.
	set(value):
		enabled = value
		
		if not value:
			if _mouse_inside:
				_mouse_inside = false
				unhover()
			
			disable()
# ==============================================================================
var _mouse_inside := false
# ==============================================================================
@onready var control: Control = get_parent() ## The control this grabber acts on.
@onready var hovered := control.mouse_entered ## Emitted when the [member control] is hovered.
@onready var unhovered := control.mouse_exited ## Emitted when the [member control] is no longer hovered.
# ==============================================================================
signal interacted() ## Emitted when the [member control] gets interacted with (left click or Q).
signal second_interacted() ## Emitted when the [member control] gets second interacted with (right click or E).
# ==============================================================================

func _init(_main: bool = false) -> void:
	main = _main


func _ready() -> void:
	hovered.connect(func() -> void:
		if enabled:
			_mouse_inside = true
	)
	unhovered.connect(func() -> void:
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
