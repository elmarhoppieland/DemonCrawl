extends TextureRect
class_name CellObjectTexture

# ==============================================================================
@export var background: CellBackground
# ==============================================================================
var cell_object: CellObject :
	set(value):
		cell_object = value
		
		if not owner:
			await get_tree().process_frame
		
		if not cell_object:
			texture = null
			stop_anim()
			return
		
		if background.state == CellBackground.State.OPEN:
			texture = cell_object.get_texture()
			
			var palette := cell_object.get_palette()
			if palette:
				material.set_shader_parameter("palette_enabled", true)
				material.set_shader_parameter("palette", palette)
			else:
				material.set_shader_parameter("palette_enabled", false)
			
			play_anim()
			return
		
		texture = null
		stop_anim()

var _tween: Tween
# ==============================================================================
@onready var tooltip_grabber: TooltipGrabber = get_child(0)
# ==============================================================================

func _ready() -> void:
	hide()
	
	await owner.opened
	
	show()


func play_anim() -> void:
	var anim_frame_duration := cell_object.get_animation_delta()
	if is_nan(anim_frame_duration):
		return
	
	if not texture or not texture is TextureSequence:
		return
	
	stop_anim()
	_tween = create_tween().set_loops()
	_tween.tween_interval(anim_frame_duration)
	_tween.tween_callback(texture.next)


func stop_anim() -> void:
	if _tween:
		_tween.kill()
