@tool
extends Control
class_name Cell

## A cell on a [Board].

# ==============================================================================
## The various states a [Cell] can be in.
const Mode := CellData.Mode

const CELL_SIZE := Vector2i(16, 16) ## The size of a [Cell] in pixels.
# ==============================================================================
@export var _data: CellData : set = set_data, get = get_data
# ==============================================================================
var _board_position := Vector2i.ZERO : get = get_board_position
# ==============================================================================
@onready var _text_particles: TextParticles = %TextParticles
@onready var _texture_shatter: TextureShatter = %TextureShatter : get = get_texture_shatter
@onready var _direction_arrow: Sprite2D = %DirectionArrow
# ==============================================================================
signal mode_changed(mode: Mode) ## Emitted when the [enum Mode] (see [method get_mode]) of this [Cell] changes.
signal value_changed(value: int) ## Emitted when the value (see [method get_value]) of this [Cell] changes.
signal object_changed(object: CellObject) ## Emitted when the object (see [method get_object]) of this [Cell] changes.
signal aura_changed(aura: Aura) ## Emitted when the [Aura] (see [method get_aura]) of this [Cell] changes.

signal data_assigned()

signal changed() ## Emitted when any of this [Cell]'s properties changes.
# ==============================================================================

## Creates and returns a new [Cell] from its [PackedScene].
static func create(board_position: Vector2i = Vector2i.ZERO) -> Cell:
	var cell := preload("res://engine/scenes/stage_scene/board/cell.tscn").instantiate() as Cell
	cell._board_position = board_position
	return cell


## Adds a particle on this [Cell] showing the given text in the given color preset.
func add_text_particle(text: String, color: TextParticles.ColorPreset) -> void:
	_text_particles.text_color_preset = color
	_text_particles.text = text
	_text_particles.emitting = true


## Shows an arrow pointing in the given [param direction]. This arrow stays
## visible until it is hidden using [method hide_direction_arrow].
func show_direction_arrow(direction: Vector2i) -> void:
	if not is_node_ready():
		await ready
	_direction_arrow.rotation = Vector2(direction).angle()
	_direction_arrow.show()


## Hides the direction arrow shown by [method show_direction_arrow].
func hide_direction_arrow() -> void:
	if not is_node_ready():
		await ready
	_direction_arrow.hide()


## Returns the [TextureRect] of this [Cell]'s object.
func get_object_texture_rect() -> CellObjectTextureRect:
	return %CellObjectTextureRect


## Returns this [Cell]'s [CellValueLabel].
func get_value_label() -> CellValueLabel:
	return %CellValueLabel


## Returns this [Cell]'s [CellTextureRect].
## [br][br]Should not be confused with [method get_object_texture_rect], which
## returns the [CellObjectTextureRect] of this [Cell]'s object.
func get_texture_rect() -> CellTextureRect:
	return %CellTextureRect


## Returns this [Cell]'s [CellAuraModulator].
func get_aura_modulator() -> CellAuraModulator:
	return %CellAuraModulator


## Returns this [Cell]'s [TextureShatter] instance.
func get_texture_shatter() -> TextureShatter:
	if _texture_shatter:
		return _texture_shatter
	return get_node_or_null("%TextureShatter")


## Sets the [CellData] instance of this [Cell] to [param data].
func set_data(data: CellData) -> void:
	const CONNECTIONS: Dictionary[String, String] = {
		"changed": "_data_changed",
		"shatter_requested": "shatter",
		"text_particle_requested": "add_text_particle",
		"show_direction_arrow_requested": "show_direction_arrow",
		"hide_direction_arrow_requested": "hide_direction_arrow",
		"scale_object_requested": "scale_object",
		"move_object_requested": "move_object_from"
	}
	
	if _data and _data.changed.is_connected(_data_changed):
		_data.changed.disconnect(_data_changed)
	
	if _data:
		for signal_name in CONNECTIONS:
			if _data.is_connected(signal_name, get(CONNECTIONS[signal_name])):
				_data.disconnect(signal_name, get(CONNECTIONS[signal_name]))
	
	_data = data
	
	_data_changed()
	
	if data:
		for signal_name in CONNECTIONS:
			data.connect(signal_name, get(CONNECTIONS[signal_name]))
		
		if data.direction_arrow != Vector2i.ZERO:
			show_direction_arrow(data.direction_arrow)
	
	data_assigned.emit()


func _data_changed() -> void:
	mode_changed.emit(get_mode())
	value_changed.emit(get_value())
	object_changed.emit(get_object())
	aura_changed.emit(get_aura())
	
	changed.emit()


func shatter(texture: Texture2D) -> void:
	get_texture_shatter().source_texture = texture
	get_texture_shatter().show()


@warning_ignore("shadowed_variable_base_class")
func scale_object(scale: float) -> void:
	get_object_texture_rect().get_2d_anchor().scale = scale * Vector2.ONE


func move_object_from(source: CellData) -> void:
	const ANIM_DURATION := 0.2
	
	var source_cell := get_stage().get_board().get_cell(source.get_position())
	assert(source_cell.get_index() == source.get_index())
	var source_anchor := source_cell.get_object_texture_rect().get_2d_anchor()
	var self_anchor := get_object_texture_rect().get_2d_anchor()
	var position_diff := self_anchor.get_global_transform().affine_inverse() * source_anchor.get_global_transform() * source_anchor.position
	create_tween().tween_property(self_anchor, "position", Vector2.ZERO, ANIM_DURATION).from(position_diff).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


## Returns the [CellData] instance of the [Cell].
## [br][br]Prefer using [method get_mode], [method get_value] or [method get_object]
## if only one of those values is needed.
func get_data() -> CellData:
	return _data


func _set_object(value: CellObject) -> void:
	if value:
		value._cell_position = _board_position
	_data.set_object(value)


## Returns this [Cell]'s [CellObject], if it has one. Returns [code]null[/code] if
## this [Cell] has no object.
## [br][br]See also [method is_occupied].
func get_object() -> CellObject:
	if get_data():
		return get_data().get_object()
	return null


## Removes this [Cell]'s [CellObject], if it has one.
func clear_object() -> void:
	get_object().reset()
	_set_object(null)


## Sets the mode of this [Cell] to [param mode]. The mode determines the visibility
## of this [Cell] and its contents. See [enum Mode].
func set_mode(mode: Cell.Mode) -> void:
	assert(mode != Cell.Mode.INVALID, "Cells cannot have an invalid mode.")
	_data.mode = mode


## Returns this [Cell]'s mode. See each [enum Mode] constant for more information.
## [br][br][b]Note:[/b] Prefer using [method is_revealed], [method is_hidden], [method is_flagged]
## and [method is_checking] over this method, as some [enum Mode] constants are used
## for multiple states and can therefore behave unexpectedly.
func get_mode() -> int:
	if _data:
		return _data.mode
	return Cell.Mode.INVALID


## Sets the value of this [Cell] to [param value]. The value typically indicates
## the number of nearby monsters, but can be changed by many effects.
func set_value(value: int) -> void:
	_data.value = value


## Returns this [Cell]'s value. This is usually the amount of nearby monsters, but
## various effects can change a [Cell]'s value to other values.
func get_value() -> int:
	if _data:
		return _data.value
	return 0


## Returns this [Cell]'s position on the [Board].
func get_board_position() -> Vector2i:
	return _board_position


func get_aura() -> Aura:
	if get_data():
		return get_data().get_aura()
	return null


## Returns whether this [Cell] has an [Aura].
func has_aura() -> bool:
	return get_aura() != null


## Returns this [Cell]'s [Stage].
func get_stage() -> Stage:
	return get_data().get_stage()


func _get_minimum_size() -> Vector2:
	return CELL_SIZE


func _on_interacted() -> void:
	get_data().notify_interacted()


func _on_second_interacted() -> void:
	get_data().notify_second_interacted()
