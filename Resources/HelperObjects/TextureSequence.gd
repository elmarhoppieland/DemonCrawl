@tool
extends Texture2D
class_name TextureSequence

# ==============================================================================
@export var size := Cell.CELL_SIZE :
	set(value):
		if size == value:
			return
		
		size = value.clamp(Vector2i.ZERO, Vector2i.MAX)
		
		if not atlas:
			emit_changed()
			return
		
		var tile_count_x := atlas.get_width() / value.x
		for i in _textures.size():
			var texture := _textures[i]
			texture.region = Rect2(
				Vector2i(i % tile_count_x, i / tile_count_x) * value,
				value
			)
		
		emit_changed()
		_area_changed.emit(get_tiles_area())

@export var index := 0 :
	set(value):
		if index == value:
			return
		
		if get_tiles_area() != 0:
			value = posmod(value, get_tiles_area())
		else:
			value = 0
		
		index = value
		
		emit_changed()

@export var atlas: Texture2D :
	set(value):
		if atlas == value:
			return
		
		atlas = value
		
		while _textures.size() < get_tiles_area():
			var texture := AtlasTexture.new()
			texture.margin = margin
			texture.filter_clip = filter_clip
			texture.region = Rect2(
				Vector2i(_textures.size() % get_tile_count().x, _textures.size() / get_tile_count().x) * size,
				size
			)
			_textures.append(texture)
		
		_textures.resize(get_tiles_area())
		
		for texture in _textures:
			texture.atlas = value
		
		emit_changed()
		_area_changed.emit(get_tiles_area())
@export var margin := Rect2()
@export var filter_clip := false
# ==============================================================================
var _textures: Array[AtlasTexture] = []
# ==============================================================================
signal _area_changed(area: int)
# ==============================================================================

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if not _textures.is_empty():
		_textures[index].draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if not _textures.is_empty():
		_textures[index].draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if not _textures.is_empty():
		_textures[index].draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return _textures[index].get_width()


func _get_height() -> int:
	return _textures[index].get_height()


func _has_alpha() -> bool:
	return _textures[index].has_alpha()


func is_valid() -> bool:
	if not atlas:
		return false
	if size.x == 0 or size.y == 0:
		return false
	return true


func next() -> void:
	index += 1


func previous() -> void:
	index -= 1


func animate(duration: float, elapsed: float) -> void:
	if not is_valid():
		return
	
	index = floori(elapsed / duration * get_tiles_area()) % get_tiles_area()


func create_next() -> TextureSequence:
	var sequence: TextureSequence = duplicate()
	sequence.next()
	return sequence


func get_tile_count() -> Vector2i:
	if not is_valid():
		return Vector2i.ZERO
	
	return Vector2i(atlas.get_size()) / size


func get_tiles_area() -> int:
	if not is_valid():
		return 0
	
	return (atlas.get_width() / size.x) * (atlas.get_height() / size.y)


func get_texture(idx: int) -> Texture2D:
	if idx < -_textures.size() or idx >= _textures.size():
		return null
	return _textures[idx]
