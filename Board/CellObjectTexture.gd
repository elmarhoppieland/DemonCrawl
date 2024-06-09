extends TextureRect

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

func play_flag() -> void:
	const FLAG_ANIM_DURATION := 0.1
	
	if background.state == CellBackground.State.OPEN:
		return
	
	texture = get_theme_icon("flag", "Cell")
	stretch_mode = TextureRect.STRETCH_SCALE
	
	await create_tween().tween_method(func(value):
		var margin_container: MarginContainer = get_parent_control()
		margin_container.add_theme_constant_override("margin_left", value)
		margin_container.add_theme_constant_override("margin_right", value)
		margin_container.add_theme_constant_override("margin_bottom", value)
		margin_container.add_theme_constant_override("margin_top", value)
	, size.x / 2, 0.0, FLAG_ANIM_DURATION).finished
	
	stretch_mode = TextureRect.STRETCH_KEEP_CENTERED


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
