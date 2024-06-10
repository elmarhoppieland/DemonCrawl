@tool
extends AtlasTexture
class_name TextureSequence

# ==============================================================================
@export var texture_size := Vector2i.ZERO :
	set(value):
		texture_size = value.clamp(Vector2i.ZERO, Vector2i.MAX)
		region.size = Vector2(value)
@export var index := 0 :
	set(value):
		index = maxi(value, 0)
		if get_tiles_area() > 0:
			index %= get_tiles_area()
		update()
# ==============================================================================

func update() -> void:
	if texture_size == Vector2i.ZERO:
		return
	
	region = Rect2(Vector2i(index % get_tile_count().x, index / get_tile_count().x) * texture_size, texture_size)


func next() -> void:
	index += 1


func previous() -> void:
	index -= 1


func animate(duration: float, delta: float) -> void:
	index = int(delta / duration * get_tiles_area())


func create_next() -> TextureSequence:
	var sequence: TextureSequence = duplicate()
	sequence.next()
	return sequence


func get_tile_count() -> Vector2i:
	return Vector2i(atlas.get_size()) / texture_size


func get_tiles_area() -> int:
	return (atlas.get_width() / texture_size.x) * (atlas.get_height() / texture_size.y)
