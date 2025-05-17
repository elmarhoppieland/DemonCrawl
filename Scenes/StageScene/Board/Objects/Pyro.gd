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
@export var direction := Direction.UP :
	set(value):
		direction = value
		
		while not get_cell():
			await cell_changed
		
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(7, 12)
	direction = Direction.values().pick_random()


func _ready() -> void:
	Effects.Signals.turn.connect(_turn)
	get_cell().show_direction_arrow(DIR_MAP[direction])


func _turn() -> void:
	get_cell().send_projectile(Flare, DIR_MAP[direction])


func _reset() -> void:
	get_cell().hide_direction_arrow()
	Effects.Signals.turn.disconnect(_turn)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_PYRO_FAIL"), IconManager.get_icon_data("Pyro/Frame0").create_texture())
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
