@tool
extends EditorPlugin
class_name __CustomTexturePreviewPlugin

# ==============================================================================
var plugin: __CustomTexturePreviewInspectorPlugin
# ==============================================================================

func _enter_tree() -> void:
	plugin = load("res://addons/CustomTexturePreview/CustomTexturePreviewInspectorPlugin.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
