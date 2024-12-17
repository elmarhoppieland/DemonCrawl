@tool
extends Resource
class_name CellData

# ==============================================================================
@export var mode := Cell.Mode.HIDDEN :
	set(new_mode):
		mode = new_mode
		emit_changed()
@export var object: CellObject :
	set(new_object):
		object = new_object
		emit_changed()
@export var value := 0 :
	set(new_value):
		value = new_value
		emit_changed()
# ==============================================================================

func _set_mode(new_mode: Cell.Mode) -> void:
	mode = new_mode
	emit_changed()


func is_revealed() -> bool:
	return mode == Cell.Mode.VISIBLE


func is_hidden() -> bool:
	return not is_revealed()


func is_flagged() -> bool:
	return mode == Cell.Mode.FLAGGED


func get_position(instance: StageInstance = Stage.get_current().get_instance()) -> Vector2i:
	var idx := instance.cells.find(self)
	assert(idx >= 0, "The provided StageInstance does not contain this cell.")
	return Vector2i(idx % instance.get_stage().size.x, idx / instance.get_stage().size.x)


func get_nearby_cells(instance: StageInstance = Stage.get_current().get_instance()) -> Array[CellData]:
	const DIRECTIONS: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]
	
	var position := get_position(instance)
	
	var cells: Array[CellData] = []
	for dir in DIRECTIONS:
		var cell := instance.get_cell(position + dir)
		if cell:
			cells.append(cell)
	
	return cells


func get_group(instance: StageInstance = Stage.get_current().get_instance()) -> Array[CellData]:
	var group: Array[CellData] = []
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	
	while not to_explore.is_empty():
		var current_cell: CellData = to_explore.pop_front()
		if current_cell in visited:
			continue
		
		visited.append(current_cell)
		group.append(current_cell)
		
		for cell in current_cell.get_nearby_cells(instance):
			if not cell in visited and cell.value == value:
				to_explore.append(cell)
	
	return group


func get_mode() -> Cell.Mode:
	return mode
