extends CellObject
class_name CellMonster

## A monster that attacks the player when revealed.

# ==============================================================================
var name := "" :
	get:
		if name.is_empty():
			var names: PackedStringArray = Stage.get_property("monsters", "names", ["???"])
			name = names[Board.rng.randi() % names.size()]
		return name
# ==============================================================================

func get_texture() -> Texture2D:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = cell.get_theme_icon("monster_atlas", "Cell")
	return texture


func get_animation_delta() -> float:
	return 0.52


func reveal_active() -> void:
	Stats.damage(Board.rng.randi_range(StagesOverview.selected_stage.min_power, StagesOverview.selected_stage.max_power))


func get_tooltip_text() -> String:
	return name
