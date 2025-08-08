@tool
extends CellObject
class_name Monster

## A monster that attacks the player when revealed.

# ==============================================================================

func _spawn() -> void:
	name = get_origin_stage().get_property("monsters", "names", ["???"]).pick_random()


func _get_texture() -> Texture2D:
	return get_theme_icon("monster").duplicate()


func _get_source() -> Texture2D:
	return (get_theme_icon("monster") as TextureSequence).get_texture(0)


func _reveal_active() -> void:
	Quest.get_current().get_stats().damage(get_origin_stage().roll_power(), self)


func _get_annotation_title() -> String:
	return name


func _aura_apply() -> void:
	if get_cell().aura is Burning:
		kill()


func _contribute_value() -> int:
	return 1
