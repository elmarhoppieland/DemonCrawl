@tool
extends EditorPlugin
class_name __IconManagerPlugin

# ==============================================================================
const ICONS_FILE := "res://.data/IconManager/icons_data.json"
# ==============================================================================
static var main_screen: __IconManagerMainScreen
# ==============================================================================

func _enter_tree() -> void:
	if not FileAccess.file_exists(ICONS_FILE):
		FileAccess.open(ICONS_FILE, FileAccess.WRITE)


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "IconManager"


func _make_visible(visible: bool) -> void:
	if visible:
		main_screen = preload("res://addons/IconManager/IconManagerMainScreen.tscn").instantiate()
		EditorInterface.get_editor_main_screen().add_child(main_screen)
	else:
		main_screen.queue_free()
		main_screen = null
