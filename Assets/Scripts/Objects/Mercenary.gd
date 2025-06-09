@tool
extends Stranger
class_name Mercenary

# ==============================================================================
@export var cost := -1
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(1, 5)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_MERCENARY_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	var cell := get_cell()
	clear()
	var familiar := Familiar.new(get_origin_stage())
	familiar.source = get_texture()
	familiar.strong = true
	cell.set_object(familiar)


func _get_annotation_title() -> String:
	return tr("STRANGER_MERCENARY").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_MERCENARY_DESCRIPTION").format({
		"cost": cost
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
