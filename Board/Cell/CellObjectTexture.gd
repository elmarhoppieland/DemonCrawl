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

var _animation_playing := false
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
	
	_animation_playing = true
	while true:
		await get_tree().create_timer(anim_frame_duration).timeout
		if not _animation_playing:
			break
		texture.next()


func stop_anim() -> void:
	_animation_playing = false
