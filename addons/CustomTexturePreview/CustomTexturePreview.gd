@tool
extends Control
class_name CustomTexturePreview

# ==============================================================================
@export var texture: Texture2D :
	set(value):
		texture = value
		
		if not is_node_ready():
			await ready
		
		texture_rect.texture = value
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
# ==============================================================================

func _ready() -> void:
	reset_size()


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		return Vector2.ZERO
	return texture_rect.get_minimum_size()


static func add_remap(script: Script, property: StringName) -> void:
	__CustomTexturePreviewInspectorPlugin._remaps[script] = property
