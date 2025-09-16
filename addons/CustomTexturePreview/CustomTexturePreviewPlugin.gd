@tool
extends EditorPlugin
class_name __CustomTexturePreviewPlugin

# ==============================================================================
const SETTING_REMAPS := "plugin/custom_texture_preview/remaps"
# ==============================================================================
var plugin: __CustomTexturePreviewInspectorPlugin
# ==============================================================================

func _enter_tree() -> void:
	plugin = load("res://addons/CustomTexturePreview/CustomTexturePreviewInspectorPlugin.gd").new()
	add_inspector_plugin(plugin)
	
	if not ProjectSettings.has_setting(SETTING_REMAPS):
		ProjectSettings.set_setting(SETTING_REMAPS, {})
		ProjectSettings.set_initial_value(SETTING_REMAPS, {})


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
