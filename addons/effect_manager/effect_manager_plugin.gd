@tool
extends EditorPlugin
class_name __EffectManagerPlugin

# ==============================================================================
const USER_FILES_DIR := "res://effect_manager/"
# ==============================================================================
static var main_screen: __EffectManagerMainScreen
# ==============================================================================

func _enter_tree() -> void:
	if not DirAccess.dir_exists_absolute(USER_FILES_DIR):
		DirAccess.make_dir_absolute(USER_FILES_DIR)
	
	if not FileAccess.file_exists(USER_FILES_DIR.path_join("effect_signals.gd")):
		var effect_signals := GDScript.new()
		effect_signals.source_code = "extends RefCounted
class_name __EffectSignals

"
		effect_signals.reload()
		
		ResourceSaver.save(effect_signals, USER_FILES_DIR.path_join("effect_signals.gd"))
	
	if not FileAccess.file_exists(USER_FILES_DIR.path_join("effects.gd")):
		var effects := GDScript.new()
		effects.source_code = "@tool
extends Object
class_name Effects

# ==============================================================================
static var Signals := __EffectSignals.new()
static var MutableSignals := __EffectSignals.new()
# =============================================================================="
		effects.reload()
		
		ResourceSaver.save(effects, USER_FILES_DIR.path_join("effects.gd"))


func _exit_tree() -> void:
	pass


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "EffectManager"


func _make_visible(visible: bool) -> void:
	if not main_screen:
		main_screen = preload("res://addons/effect_manager/effect_manager_main_screen.tscn").instantiate()
		EditorInterface.get_editor_main_screen().add_child(main_screen)
	
	main_screen.visible = visible


static func get_type_color(color_name: String) -> Color:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/".path_join(color_name))
	
	match color_name:
		"keyword_color":
			return Color("ff7085")
		"base_type_color":
			return Color("42ffc2")
		"engine_type_color":
			return Color("8fffdb")
		"user_type_color":
			return Color("c7ffed")
	
	return Color.WHITE


static func get_function_definition_color() -> Color:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/function_definition_color")
	
	return Color("66e6ff")
