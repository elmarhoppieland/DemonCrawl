@tool
extends Stranger
class_name Pyro

# ==============================================================================
const DIR_MAP := {
	Direction.UP: Vector2i.UP,
	Direction.RIGHT: Vector2i.RIGHT,
	Direction.DOWN: Vector2i.DOWN,
	Direction.LEFT: Vector2i.LEFT,
}
# ==============================================================================
enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}
# ==============================================================================
@export var cost := -1
@export var direction := Direction.UP
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(7, 12)
	direction = Direction.values().pick_random()


func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.connect(_turn)
	if get_cell().is_visible():
		get_cell().show_direction_arrow(DIR_MAP[direction])


func _turn() -> void:
	if get_cell().is_visible():
		get_cell().send_projectile(Flare, DIR_MAP[direction])


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.disconnect(_turn)
	get_cell().hide_direction_arrow()


func _reveal() -> void:
	get_cell().show_direction_arrow(DIR_MAP[direction])


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_PYRO_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	direction = (direction + 1) % Direction.size() as Direction
	get_cell().show_direction_arrow(DIR_MAP[direction])


func _get_annotation_title() -> String:
	return tr("STRANGER_PYRO").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_PYRO_DESCRIPTION").format({
		"cost": cost
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
