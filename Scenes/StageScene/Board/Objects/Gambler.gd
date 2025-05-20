@tool
extends Stranger
class_name Gambler

# ==============================================================================
@export var cost := -1
@export var coins := -1
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(5, 15)
	coins = randi_range(10, 20)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_GAMBLER_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	coins += cost
	
	activate()


func _activate() -> void:
	Toasts.add_toast(tr("STRANGER_GAMBLER_INTERACT"), get_source())
	
	var cells := Stage.get_current().get_instance().get_cells().filter(func(cell: CellData) -> bool:
		return cell.is_hidden() and (not cell.is_occupied() or cell.object is Monster)
	)
	if cells.is_empty():
		return
	
	var cell := cells.pick_random() as CellData
	
	cell.open(true, false)
	
	if cell.is_occupied():
		# this cell must contain a monster since we filter for this
		Quest.get_current().get_stats().coins += coins
		self.kill()
		return
	
	move_to_cell(cell)


func _get_annotation_title() -> String:
	return tr("STRANGER_GAMBLER").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_GAMBLER_DESCRIPTION").format({
		"cost": cost
	}) + "\"\n" + tr("STRANGER_GAMBLER_BALANCE").format({
		"coins": coins
	})
