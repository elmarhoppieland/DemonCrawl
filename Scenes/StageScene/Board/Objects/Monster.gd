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
	#if Engine.is_editor_hint():
		#var texture := TextureSequence.new()
		#texture.atlas = preload("res://Assets/skins/forest/monster.png")
		#texture.size = Cell.CELL_SIZE
		#return texture
	
	var texture := TextureSequence.new()
	texture.size = Cell.CELL_SIZE
	texture.atlas = get_theme_icon("monster_atlas", "Cell")
	return texture


func _get_animation_delta() -> float:
	return 0.5


func _reveal_active() -> void:
	Quest.get_current().get_stats().damage(Stage.get_current().roll_power(), self)


func _get_annotation_title() -> String:
	return name


func _animate(time: float) -> void:
	get_texture().animate(1.0, time)
