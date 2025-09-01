@tool
extends Stranger
class_name Waterboy

# ==============================================================================
const DIR_MAP: Dictionary[Direction, Vector2i] = {
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
	cost = randi_range(1, 5)
	direction = Direction.values().pick_random()


func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.connect(_turn)
	if get_cell().is_visible():
		get_cell().show_direction_arrow(DIR_MAP[direction])


func _turn() -> void:
	if get_cell().is_visible():
		get_cell().send_projectile(BubbleProjectile, DIR_MAP[direction])


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_cell().hide_direction_arrow()
	get_quest().get_stage_effects().turn.disconnect(_turn)


func _reveal() -> void:
	get_cell().show_direction_arrow(DIR_MAP[direction])


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("stranger.waterboy.fail"), get_source())
		return
	
	if not can_move():
		Toasts.add_toast(tr("stranger.waterboy.move.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	if can_move():
		var new_pos: Vector2i = get_cell().get_position() + DIR_MAP[direction]
		var new_cell := get_cell().get_stage_instance().get_cell(new_pos)
		move_to_cell(new_cell)


func _get_annotation_title() -> String:
	return tr("stranger.waterboy").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("stranger.waterboy.description").format({
		"cost": cost
	}) + "\""


func can_move() -> bool:
	var new_pos: Vector2i = get_cell().get_position() + DIR_MAP[direction]
	var new_cell := get_cell().get_stage_instance().get_cell(new_pos)
	return new_cell != null and new_cell.is_empty() and new_cell.is_visible()


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
