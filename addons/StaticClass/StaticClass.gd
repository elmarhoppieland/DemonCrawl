extends Object
class_name StaticClass

# ==============================================================================

func _init() -> void:
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.path == get_script().resource_path:
			assert(false, "Static class '%s' cannot be instantiated. Instead, call methods on the class directly." % class_data.class)
