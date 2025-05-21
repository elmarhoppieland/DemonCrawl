@tool
extends EditorPlugin

# ==============================================================================
const DEPENDENCIES: PackedStringArray = ["UserClassDB", "Stringifier"]
# ==============================================================================

func _enter_tree() -> void:
	var found := PackedStringArray()
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.class in DEPENDENCIES:
			found.append(class_data.class)
	
	for dependency in DEPENDENCIES:
		assert(dependency in found, "Eternity: Missing dependency: " + dependency + ".")
	
	if not ProjectSettings.has_setting("eternity/named_paths/defaults"):
		ProjectSettings.set_setting("eternity/named_paths/defaults", {
			"settings": "user://settings.ini"
		})
	if not ProjectSettings.has_setting("eternity/editor/editor_save_path"):
		ProjectSettings.set_setting("eternity/editor/editor_save_path", "")
	
	Eternity._editor_init()


func _enable_plugin() -> void:
	if not ProjectSettings.has_setting("eternity/named_paths/defaults"):
		ProjectSettings.set_setting("eternity/named_paths/defaults", {
			"settings": "user://settings.ini"
		})
		ProjectSettings.set_initial_value("eternity/named_paths/defaults", {
			"settings": "user://settings.ini"
		})
	if not ProjectSettings.has_setting("eternity/editor/editor_save_path"):
		ProjectSettings.set_setting("eternity/editor/editor_save_path", "")
		ProjectSettings.set_initial_value("eternity/editor/editor_save_path", "")
	
	ProjectSettings.set_as_internal("eternity/named_paths/defaults", false)
	ProjectSettings.set_as_internal("eternity/editor/editor_save_path", false)


func _disable_plugin() -> void:
	ProjectSettings.set_as_internal("eternity/named_paths/defaults", true)
	ProjectSettings.set_as_internal("eternity/editor/editor_save_path", true)
