extends StageFileBase
class_name CombinedStageFile

# ==============================================================================
@export var primary_stage: StageFile
@export var secondary_stage: StageFile
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(primary_stage: StageFile, secondary_stage: StageFile) -> void:
	self.primary_stage = primary_stage
	self.secondary_stage = secondary_stage


func _create_theme() -> Theme:
	# TODO: this is not 100% accurate
	
	var theme := Theme.new()
	
	theme.set_icon("bg", "Cell", CombinedTexture2D.new(primary_stage.cell_bg, secondary_stage.cell_bg))
	theme.set_icon("checking", "Cell", secondary_stage.cell_checking)
	
	if primary_stage.cell_coin_palette or secondary_stage.cell_coin_palette:
		theme.set_icon("coin_palette", "Cell", CombinedTexture2D.static_combine(primary_stage.cell_coin_palette, secondary_stage.cell_coin_palette))
	
	if primary_stage.cell_heart_palette or secondary_stage.cell_heart_palette:
		theme.set_icon("heart_palette", "Cell", CombinedTexture2D.static_combine(primary_stage.cell_heart_palette, secondary_stage.cell_heart_palette))
	
	theme.set_icon("flag", "Cell", secondary_stage.cell_flag)
	theme.set_icon("flag_bg", "Cell", primary_stage.cell_flag_bg)
	theme.set_icon("hidden", "Cell", secondary_stage.cell_hidden)
	
	theme.set_icon("bg", "StageScene", primary_stage.bg)
	
	return theme


func _get_name() -> String:
	return tr("generic.combined-stage").format({
		"primary": tr(primary_stage.get_stage_name()),
		"secondary": tr(secondary_stage.adjective)
	})


func _get_bg() -> Texture2D:
	return primary_stage.get_bg()


func _get_music() -> AudioStream:
	return secondary_stage.get_music()


func _get_ambience_a() -> AudioStream:
	return primary_stage.get_ambience_a()


func _get_ambience_b() -> AudioStream:
	return secondary_stage.get_ambience_b()


func _get_artifacts() -> Array[StageFile]:
	var artifacts := primary_stage.get_artifacts()
	artifacts.append_array(secondary_stage.get_artifacts())
	return artifacts


func _export_packed() -> Array:
	return [primary_stage, secondary_stage]


class CombinedTexture2D extends Texture2D:
	var _texture_a: Texture2D
	var _texture_b: Texture2D
	
	func _init(texture_a: Texture2D, texture_b: Texture2D) -> void:
		_texture_a = texture_a
		_texture_b = texture_b
	
	func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
		_texture_a.draw(to_canvas_item, pos, modulate, transpose)
		_texture_b.draw(to_canvas_item, pos, modulate * Color(1, 1, 1, 0.5), transpose)
	
	func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
		_texture_a.draw_rect(to_canvas_item, rect, tile, modulate, transpose)
		_texture_b.draw_rect(to_canvas_item, rect, tile, modulate * Color(1, 1, 1, 0.5), transpose)
	
	func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
		_texture_a.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)
		_texture_b.draw_rect_region(to_canvas_item, rect, src_rect, modulate * Color(1, 1, 1, 0.5), transpose, clip_uv)
	
	func _get_width() -> int:
		return maxi(_texture_a.get_width(), _texture_b.get_width())
	
	func _get_height() -> int:
		return maxi(_texture_a.get_height(), _texture_b.get_height())
	
	func _has_alpha() -> bool:
		return _texture_a.has_alpha() or _texture_b.has_alpha()
	
	static func static_combine(texture_a: Texture2D, texture_b: Texture2D) -> Texture2D:
		if not texture_a:
			return texture_b
		if not texture_b:
			return texture_a
		
		assert(texture_a.get_size() == texture_b.get_size(), "Only same-size textures are supported when merging.")
		
		var image_a := texture_a.get_image()
		var image_b := texture_b.get_image()
		
		var image := Image.create(image_a.get_width(), image_a.get_height(), false, Image.FORMAT_RGBA8)
		for x in image_a.get_width():
			for y in image_a.get_height():
				image.set_pixel(x, y, image_a.get_pixel(x, y).blend(image_b.get_pixel(x, y) * Color(1, 1, 1, 0.5)))
		
		return ImageTexture.create_from_image(image)
