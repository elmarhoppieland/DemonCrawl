@tool
extends CellObject
class_name Monster

## A monster that attacks the player when revealed.

# ==============================================================================
@export var name := "" :
	get:
		if name.is_empty() and get_origin_stage():
			var names: PackedStringArray = get_origin_stage().get_property("monsters", "names", ["???"])
			name = names[randi() % names.size()]
		return name
# ==============================================================================

func _get_texture() -> Texture2D:
	return get_theme_icon("monster").duplicate()


func _get_source() -> Texture2D:
	return (get_theme_icon("monster") as TextureSequence).get_texture(0)


func _reveal_active() -> void:
	Quest.get_current().get_stats().damage(get_origin_stage().roll_power(), self)


func _get_annotation_title() -> String:
	return name


func _aura_apply() -> void:
	if get_cell().get_aura() is Burning:
		kill()


func _kill() -> void:
	for cell in get_cell().get_nearby_cells():
		cell.value -= 1
