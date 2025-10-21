extends Camera2D
class_name StageCamera

# ==============================================================================
const DEFAULT_ZOOM := Vector2(3, 3)
const ZOOM_BEGIN := Vector2(0.75, 0.75)
# ==============================================================================
@export var stage_instance: StageInstance = null :
	get:
		if stage_instance == null:
			return StageScene.get_instance().stage_instance
		return stage_instance

@export var move_speed := 0.0
@export var shake_magnitude := 2.0
@export var shake_duration := 0.2
# ==============================================================================
var shake_enabled := false
var last_mouse_pos := Vector2.ZERO

var _zoom_tween: Tween
# ==============================================================================

func _ready() -> void:
	if stage_instance.was_reloaded():
		zoom = DEFAULT_ZOOM
	else:
		create_tween().tween_property(self, "zoom", DEFAULT_ZOOM, 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).from(ZOOM_BEGIN)


func _process(delta: float) -> void:
	var input_vector := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	position += move_speed * input_vector * delta / zoom
	
	if Input.is_action_pressed("grab_screen"):
		input_vector = last_mouse_pos - get_viewport().get_mouse_position()
		position += input_vector / zoom
	
	last_mouse_pos = get_viewport().get_mouse_position()
	
	var scroll := int(Input.is_action_just_released("zoom_in")) - int(Input.is_action_just_released("zoom_out"))
	if scroll != 0:
		if _zoom_tween:
			_zoom_tween.kill()
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(self, "zoom", (zoom * (1.5 ** scroll)).round(), 0.1)
	
	if shake_enabled:
		offset = Vector2.RIGHT.rotated(randf_range(-PI, PI)) * shake_magnitude
	else:
		offset = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_copy"):
		shake()
	if Input.is_action_just_pressed("ui_cut"):
		var tween := create_tween()
		tween.tween_property(self, "zoom", DEFAULT_ZOOM, 4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).from(ZOOM_BEGIN)


func shake() -> void:
	shake_enabled = true
	await get_tree().create_timer(shake_duration).timeout
	shake_enabled = false


func focus_on_cell(cell: CellData) -> void:
	global_position = stage_instance.get_board().get_global_at_cell_position(cell.get_position())
