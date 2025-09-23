@tool
extends Control
class_name Board

# ==============================================================================
const CELL_SEPARATION := Vector2i(1, 1)
# ==============================================================================
@export var stage_instance: StageInstance = null :
	get:
		if stage_instance == null and StageScene.get_instance():
			return StageScene.get_instance().stage_instance
		return stage_instance
# ==============================================================================
@onready var _cell_container: BoardCellContainer = %BoardCellContainer :
	get:
		if not _cell_container and has_node("%BoardCellContainer"):
			_cell_container = %BoardCellContainer
		return _cell_container
@onready var _camera: StageCamera = %StageCamera : get = get_camera
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name == "stage_instance" and owner is StageScene:
		property.usage |= PROPERTY_USAGE_READ_ONLY


## Returns whether any [Cell] is currently hovered.
func has_hovered_cell() -> bool:
	return get_hovered_cell() != null


## Returns the currently hovered [Cell]. Returns [code]null[/code] if no [Cell] is hovered.
func get_hovered_cell() -> CellData:
	return _cell_container.get_hovered_cell()


## Returns the [Cell] at the given board position.
func get_cell(at: Vector2i) -> Cell:
	if at.x < 0 or at.y < 0:
		return null
	if at.x >= stage_instance.get_stage().size.x or at.y >= stage_instance.get_stage().size.y:
		return null
	return _cell_container.get_child(at.x + at.y * stage_instance.get_stage().size.x)


## Returns the [Cell] at the given [param global] position.
func get_cell_at_global(global: Vector2) -> Cell:
	return get_cell(get_cell_position_at_global(global))


## Returns the global position at the given [param cell_position].
func get_global_at_cell_position(cell_position: Vector2i, centered: bool = true) -> Vector2:
	var global := Vector2(cell_position * (Cell.CELL_SIZE + CELL_SEPARATION))
	if centered:
		global += Vector2(Cell.CELL_SIZE) / 2
	return get_global_transform() * global


func get_cell_position_at_global(global: Vector2) -> Vector2i:
	return Vector2i(global * get_global_transform()) / (Cell.CELL_SIZE + CELL_SEPARATION)


## Returns an [Array] of all [Cell]s.
func get_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	cells.assign(_cell_container.get_children())
	return cells


## Returns the [Board]'s camera.
func get_camera() -> StageCamera:
	return _camera


# TODO
func needs_guess() -> bool:
	return false


func _get_minimum_size() -> Vector2:
	return _cell_container.get_minimum_size()
