extends CellObject
class_name CellMonster

## A monster that attacks the player.

# ==============================================================================

func get_texture(theme: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("main")
	frames.set_animation_speed("main", 1.92308)
	frames.add_frame("main", ResourceLoader.load(theme.path_join("monster0.png")))
	frames.add_frame("main", ResourceLoader.load(theme.path_join("monster1.png")))
	return frames
