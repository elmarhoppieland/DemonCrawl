@tool
extends EditorInspectorPlugin
class_name __CustomTexturePreviewInspectorPlugin

# ==============================================================================
static var _remaps := {}
# ==============================================================================

func _can_handle(object: Object) -> bool:
	return object.get_script() != null and object.get_script().get_instance_base_type() == &"Texture2D"


func _parse_begin(object: Object) -> void:
	const CUSTOM_TEXTURE_PREVIEW := preload("res://addons/CustomTexturePreview/CustomTexturePreview.tscn")
	
	var preview := CUSTOM_TEXTURE_PREVIEW.instantiate() as CustomTexturePreview
	if object.get_script() in _remaps:
		preview.texture = object.get(_remaps[object.get_script()])
	else:
		preview.texture = object
	add_custom_control(preview)
