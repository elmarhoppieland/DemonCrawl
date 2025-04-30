@tool
extends GPUParticles2D
class_name TextureShatter

# ==============================================================================
@export var source_texture: Texture2D :
	set(value):
		source_texture = value
		
		if not is_node_ready():
			await ready
		
		texture = value
		if value:
			(material as CanvasItemMaterial).particles_anim_h_frames = value.get_width()
			(material as CanvasItemMaterial).particles_anim_v_frames = value.get_height()
			
			visibility_rect = Rect2(-value.get_size() / 2, value.get_size()).grow(lifetime * (process_material as ParticleProcessMaterial).radial_velocity_max * 2)
# ==============================================================================

func _ready() -> void:
	visibility_changed.connect(func() -> void:
		if not visible:
			return
		
		restart()
		
		await finished
		
		hide()
	)
