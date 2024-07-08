extends Camera2D
class_name StageCamera

# ==============================================================================
static var _instance: StageCamera
# ==============================================================================
@export var move_speed := 0.0
@export var shake_magnitude := 2.0
@export var shake_duration := 0.2
# ==============================================================================
var shake_enabled := false

var _zoom_tween: Tween
# ==============================================================================

func _init() -> void:
	_instance = self


func _ready() -> void:
	await owner.ready
	position = Board.board_size / 2 * Board.CELL_SIZE
	
	create_tween().tween_property(self, "zoom", Vector2.ONE * 2, 1).set_trans(Tween.TRANS_QUAD)


func _process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += move_speed * input_vector * delta
	
	var scroll := int(Input.is_action_just_released("zoom_in")) - int(Input.is_action_just_released("zoom_out"))
	if scroll != 0:
		if _zoom_tween:
			_zoom_tween.kill()
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(self, "zoom", (zoom * (1.5 ** scroll)).round(), 0.1)
	
	
	if shake_enabled:
		offset = Vector2.RIGHT.rotated(Board.rng.randf_range(-PI, PI)) * shake_magnitude
	else:
		offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_copy"):
		StageCamera.shake()


static func shake() -> void:
	if not _instance:
		return
	
	_instance.shake_enabled = true
	await _instance.get_tree().create_timer(_instance.shake_duration).timeout
	_instance.shake_enabled = false


static func get_zoom_level() -> Vector2:
	return _instance.zoom


static func focus_progress() -> void:
	_instance.position = Board.get_progress_cell().board_position * Board.CELL_SIZE


static func get_center() -> Vector2:
	if _instance:
		return _instance.position
	
	# we need any node to get the main viewport here, Focus works here but anything else also works
	return Focus.get_viewport().size / 2
