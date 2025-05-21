@tool
extends CellObject
class_name Familiar

# ==============================================================================
@export var source: Texture2D = null:
	set(value):
		source = value
		emit_changed()
	get:
		if source == null:
			source = AnimatedTextureSequence.new()
			source.atlas = preload("res://Assets/Sprites/Familiar.png")
		return source
@export var strong := false
# ==============================================================================

func _get_texture() -> Texture2D:
	return source


func _get_modulate() -> Color:
	return Color.GREEN


func _ready() -> void:
	Effects.Signals.turn.connect(_turn)


func _reset() -> void:
	Effects.Signals.turn.disconnect(_turn)


func _turn() -> void:
	const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	
	var position := get_cell().get_position()
	var dirs: Array[Vector2i] = DIRS.duplicate()
	dirs.shuffle()
	for dir in dirs:
		var new_cell := Stage.get_current().get_instance().get_cell(position + dir)
		if not can_move_to(new_cell):
			continue
		
		new_cell.open(true)
		if new_cell.object is Monster:
			if strong:
				new_cell.object.kill()
				move_to_cell(new_cell)
			else:
				clear()
			return
		
		if not can_move_to(new_cell):
			# something has spawned that blocks our way
			return
		
		if new_cell.is_occupied():
			new_cell.object.notify_interacted()
		
		move_to_cell(new_cell)
		return


func can_move_to(cell: CellData) -> bool:
	if cell == null:
		return false
	if not cell.is_occupied():
		return true
	if cell.object is Monster:
		return strong or (cell.is_hidden() and not cell.is_flagged())
	return cell.object.get_script() in [Coin, Diamond, Heart]


func _get_annotation_title() -> String:
	return tr("FAMILIAR").to_upper()


func _get_annotation_subtext() -> String:
	if strong:
		return tr("FAMILIAR_STRONG_DESCRIPTION")
	return tr("FAMILIAR_DESCRIPTION")


func _aura_apply() -> void:
	if get_cell().aura is Burning:
		kill()


func _cell_enter() -> void:
	_aura_apply()
