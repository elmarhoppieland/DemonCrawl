@tool
extends CellObject
class_name Monster

## A monster that attacks the player when revealed.

# ==============================================================================
var name := "" :
	get:
		if name.is_empty() and Stage.has_current():
			var names: PackedStringArray = Stage.get_current().get_property("monsters", "names", ["???"])
			name = names[randi() % names.size()]
		return name
# ==============================================================================

func _get_texture() -> Texture2D:
	return get_theme_icon("monster").duplicate()


func _reveal_active() -> void:
	Quest.get_current().get_stats().damage(Stage.get_current().roll_power(), self)


func _get_annotation_title() -> String:
	return name
