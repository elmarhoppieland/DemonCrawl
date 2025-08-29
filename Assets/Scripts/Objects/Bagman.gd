@tool
extends Stranger
class_name Bagman

# ==============================================================================
@export var cost := -1
@export var power := 0
# ==============================================================================

func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stats().get_mutable_effects().damage.connect(_damage)


func _spawn() -> void:
	cost = randi_range(5, 10)
	power = randi_range(1, 3)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stats().get_mutable_effects().damage.disconnect(_damage)


func _damage(amount: int, source: Object) -> int:
	if source is Monster:
		amount += power
	return maxi(0, amount)


func _interact() -> void:
	if power <= -3:
		return
	
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_BAGMAN_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	activate()


func _activate() -> void:
	power -= 1
	Toasts.add_toast(tr("STRANGER_BAGMAN_INTERACT"), get_source())


func _get_annotation_title() -> String:
	return tr("STRANGER_BAGMAN").to_upper()


func _get_annotation_subtext() -> String:
	var msg := ""
	
	if power > 0:
		msg += tr("STRANGER_BAGMAN_DESCRIPTION_EMPOWER").format({
			"power": power
		}) + "\n"
	elif power == 0:
		msg += tr("STRANGER_BAGMAN_DESCRIPTION_NEUTRAL") + "\n"
	else:
		msg += tr("STRANGER_BAGMAN_DESCRIPTION_WEAKEN").format({
			"power": -power
		}) + "\n"
	
	if power > -3:
		msg += tr("STRANGER_BAGMAN_DESCRIPTION_PROMPT").format({
			"cost": cost
		})
	
	return "\"" + msg.strip_edges() + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
