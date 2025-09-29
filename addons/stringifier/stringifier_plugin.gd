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
		assert(dependency in found, "Stringifier: Missing dependency: " + dependency + ".")
