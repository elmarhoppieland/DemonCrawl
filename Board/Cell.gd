extends Node2D
class_name Cell

## A single cell in a [Board].

# ==============================================================================
const _NEIGHBORS: Array[Vector2i] = [
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.LEFT
]
# ==============================================================================
static var _flag_sprite_frames: SpriteFrames
# ==============================================================================
## This cell's theme. Its sprites are pulled from this directory inside [code]res://Assets/skins[/code].
var theme := ""
var cell_value := 0 ## This cell's value, i.e. the number of adjacent monsters.
var revealed := false ## Whether this cell has been revealed.
var flagged := false : ## Whether this cell has been flagged. Always [code]false[/code] if this cell is visible.
	get: return flagged and not revealed
var board_position := Vector2i.ZERO ## This cell's [Board] coordinates.

var cell_object: CellObject ## This cell's [CellObject], e.g. loot or a monster.
# ==============================================================================
@onready var _background_sprite: AnimatedSprite2D = %BackgroundSprite
@onready var _value_label: Label = %ValueLabel
@onready var _object_sprite: AnimatedSprite2D = %ObjectSprite
# ==============================================================================
signal cell_opened() ## Emitted when this cell gets opened.
signal cell_flagged() ## Emitted when this cell gets flagged (not unflagged).
# ==============================================================================

## Updates all of this cell's sprites. Call this after making many changes that
## should cause a visual update.
## [br][br]See also [method update_background_sprite], [method update_value_label] and
## [method update_object_sprite].
func update_sprites() -> void:
	update_background_sprite()
	
	update_value_label()
	
	update_object_sprite()


## Updates this cell's background sprite.
## [br][br]See also [method update_sprites].
func update_background_sprite() -> void:
	if not _background_sprite:
		await ready
	
	var path := theme.path_join("empty.png" if revealed else "flag_bg.png" if flagged else "full.png")
	_set_bg_texture(ResourceLoader.load(path))


## Updates this cell's value visually. Call this after changing [member cell_value].
## [br][br]See also [method update_sprites].
func update_value_label() -> void:
	if not _value_label:
		await ready
	
	_value_label.visible = revealed and not cell_object
	_value_label.text = str(cell_value) if cell_value > 0 else ""


## Updates this cell's object sprite. This sets the foreground sprite's texture to
## [method CellObject.get_texture].
## [br][br]See also [method update_sprites].
func update_object_sprite() -> void:
	if not _object_sprite:
		await ready
	
	if flagged:
		_object_sprite.visible = true
		_object_sprite.sprite_frames = _flag_sprite_frames
		_object_sprite.play("main")
		_object_sprite.scale = Vector2.ZERO
		create_tween().tween_property(_object_sprite, "scale", Vector2.ONE, 0.1)
		return
	
	_object_sprite.visible = revealed
	if cell_object:
		_object_sprite.sprite_frames = cell_object.get_texture(theme)
		_object_sprite.play("main")
		return
	
	if not flagged:
		_object_sprite.sprite_frames = null
		return


## Loads the [CellData] into this cell. Also calls [method update_sprites].
func load_data(data: CellData) -> void:
	theme = data.theme
	cell_value = data.cell_value
	revealed = data.revealed
	cell_object = data.cell_object
	
	if not _flag_sprite_frames:
		_flag_sprite_frames = SpriteFrames.new()
		_flag_sprite_frames.add_animation("main")
		_flag_sprite_frames.add_frame("main", ResourceLoader.load(theme.path_join("flag.png")))
	
	update_sprites()


## Sets this cell's value to the number of adjacent monsters.
func reset_value() -> void:
	cell_value = 0
	for cell in get_nearby_cells():
		if cell.cell_object:
			cell_value += 1
	
	update_value_label()


## If this cell is visible, visually presses this cell down. If this is a hidden cell, chords this cell,
## pressing down all adjacent hidden cells.
## [br][br]Does nothing if this cell is [member flagged].
func press() -> void:
	if flagged:
		return
	if revealed:
		if is_occupied():
			return
		
		for cell in get_nearby_cells():
			if not cell.revealed and not cell.flagged:
				cell.press()
		return
	
	_set_bg_texture(ResourceLoader.load(theme.path_join("checking.png")))


## If this cell is visible, visually unpresses this cell. If this is a hidden cell, unchords this cell,
## unpressing all adjacent hidden cells.
## [br][br]Does nothing if this cell is [member flagged].
func unpress() -> void:
	if flagged:
		return
	if revealed:
		if is_occupied():
			return
		
		for cell in get_nearby_cells():
			if cell.revealed:
				continue
			cell.unpress()
		return
	
	update_background_sprite()


## If this cell is visible, opens the cell, revealing all adjacent cells if this is a 0.
## If it is a hidden cell, chords this cell. This either opens all adjacent cells if this cell is solved
## (see [method is_solved]), or unpresses all adjacent cells (see [method unpress]).
## [br][br]Does nothing if this cell is [member flagged].
func open() -> void:
	if flagged:
		return
	if revealed:
		if is_occupied():
			return
		
		for cell in get_nearby_cells():
			if cell.revealed:
				continue
			if cell.flagged:
				continue
			if is_solved():
				cell.open()
			else:
				cell.unpress()
		return
	
	revealed = true
	update_sprites()
	
	cell_opened.emit()
	
	if cell_value == 0:
		for cell in get_nearby_cells():
			cell.open()


## Flags or unflags this cell. If it is already visible and has exactly [member cell_value] monsters
## in nearby cells, flags all nearby hidden cells instead.
func flag() -> void:
	if revealed:
		if is_occupied():
			return
		
		var cell_count := 0
		for cell in get_nearby_cells():
			if not cell.revealed or cell.has_monster():
				cell_count += 1
		
		if cell_count == cell_value:
			for cell in get_nearby_cells():
				if not cell.revealed and not cell.flagged:
					cell.flag()
		
		return
	
	flagged = not flagged
	update_sprites()
	
	if flagged:
		cell_flagged.emit()


## Returns all cells orthogonally or diagonally adjacent to this cell. See also [method Board.get_cell].
func get_nearby_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	
	for offset in _NEIGHBORS:
		var cell := Board.get_cell(board_position + offset)
		if cell:
			cells.append(cell)
	
	return cells


## Returns whether this cell's object is a monster, even if this cell is hidden.
func has_monster() -> bool:
	if not cell_object:
		return false
	
	return cell_object is CellMonster


## Returns whether the number of nearby identified monsters is equal to or greater than this cell's value.
## [br][br]An identified monster is a flagged cell (even if it does not have a monster) or a visible monster.
func is_solved() -> bool:
	var nearby_monsters := 0
	for cell in get_nearby_cells():
		if cell.revealed:
			if cell.has_monster():
				nearby_monsters += 1
		elif cell.flagged:
			nearby_monsters += 1
	
	return nearby_monsters >= cell_value


## Returns whether is cell is occupied, i.e. whether it has an object.
func is_occupied() -> bool:
	return cell_object != null


## Creates a new cell and returns it, after loading the given [code]data[/code] into it, if it is given.
## [br][br]See also [method load_data].
static func create(data: CellData = null) -> Cell:
	var scene: PackedScene = ResourceLoader.load("res://Board/Cell.tscn")
	var cell: Cell = scene.instantiate()
	
	if data:
		cell.load_data(data)
	
	return cell


func _set_bg_texture(texture: Texture2D) -> void:
	if _background_sprite.sprite_frames.get_frame_count("static") < 1:
		_background_sprite.sprite_frames.add_frame("static", texture)
	else:
		_background_sprite.sprite_frames.set_frame("static", 0, texture)
	
	_background_sprite.play("static")
