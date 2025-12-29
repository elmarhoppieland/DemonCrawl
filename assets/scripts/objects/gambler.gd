@tool
extends Stranger
class_name Gambler

# ==============================================================================
@export var cost := -1
@export var coins := -1
# ==============================================================================

func _get_name_id() -> String:
	return "object.gambler"


func _spawn() -> void:
	cost = randi_range(5, 15)
	coins = randi_range(10, 20)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		var handled := handle_fail()
		if not handled:
			Toasts.add_toast(tr("stranger.gambler.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	coins += cost
	
	activate()


func _activate() -> void:
	Toasts.add_toast(tr("stranger.gambler.interact"), get_source())
	
	var cells := get_cell().get_stage_instance().get_cells().filter(func(cell: CellData) -> bool:
		return cell.is_hidden() and (not cell.is_occupied() or cell.has_monster())
	)
	if cells.is_empty():
		return
	
	var cell := cells.pick_random() as CellData
	
	cell.reveal(false)
	
	if cell.is_occupied():
		# this cell must contain a monster since we filter for this
		Quest.get_current().get_stats().coins += coins
		self.kill()
		return
	
	move_to_cell(cell)


func _get_annotation_title() -> String:
	return tr("stranger.gambler").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("stranger.gambler.description").format({
		"cost": cost
	}) + "\"\n" + tr("stranger.gambler.balance").format({
		"coins": coins
	})


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
