extends AtlasTexture
class_name TextureSequence

# ==============================================================================
@export var size := Vector2i.ZERO :
	set(value):
		size = value.clamp(Vector2i.ZERO, Vector2i.MAX)
		update()
@export var index := 0 :
	set(value):
		index = maxi(value, 0)
		if get_tiles_area() > 0:
			index %= get_tiles_area()
		update()
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name == "region":
		property.usage &= ~PROPERTY_USAGE_EDITOR


func update() -> void:
	if size == Vector2i.ZERO:
		return
	if not atlas:
		return
	
	region = Rect2(Vector2i(index % get_tile_count().x, index / get_tile_count().x) * size, size)
	emit_changed()


func next() -> void:
	index += 1


func previous() -> void:
	index -= 1


func animate(duration: float, delta: float) -> void:
	if not atlas:
		return
	index = int(delta / duration * get_tiles_area()) % get_tiles_area()


func create_next() -> TextureSequence:
	var sequence: TextureSequence = duplicate()
	sequence.next()
	return sequence


func get_tile_count() -> Vector2i:
	if atlas:
		return Vector2i(atlas.get_size()) / size
	return Vector2i.ZERO


func get_tiles_area() -> int:
	if not atlas:
		return 0
	return (atlas.get_width() / size.x) * (atlas.get_height() / size.y)
