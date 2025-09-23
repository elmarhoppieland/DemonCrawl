@tool
extends Resource
class_name MasteryUnlockerData

# ==============================================================================
@export var data: MasteryData = null
@export var unlocker_script: Script = null
# ==============================================================================

func _property_can_revert(property: StringName) -> bool:
	return property == &"unlocker_script"


func _property_get_revert(property: StringName) -> Variant:
	if property == &"unlocker_script":
		if unlocker_script:
			return null
		
		var path := resource_path.get_basename() + ".gd"
		if ResourceLoader.exists(path):
			return load(path)
	
	return null


func create() -> MasteryUnlocker:
	return unlocker_script.new(self)
