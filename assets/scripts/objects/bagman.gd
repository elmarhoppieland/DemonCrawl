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
	
	get_quest().get_stats().get_effects().take_damage.connect(_damage)


func _spawn() -> void:
	cost = randi_range(5, 10)
	power = randi_range(1, 3)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stats().get_effects().take_damage.disconnect(_damage)


func _damage(amount: int, source: Object) -> int:
	if source is Monster:
		amount += power
	return maxi(0, amount)


func _interact() -> void:
	if power <= -3:
		return
	
	if Quest.get_current().get_stats().coins < cost:
		var handled := handle_fail()
		if not handled:
			Toasts.add_toast(tr("stranger.bagman.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	activate()


func _activate() -> void:
	power -= 1
	Toasts.add_toast(tr("stranger.bagman.interact"), get_source())


func _get_annotation_title() -> String:
	return tr("stranger.bagman").to_upper()


func _get_annotation_subtext() -> String:
	var msg := ""
	
	if power > 0:
		msg += tr("stranger.bagman.description.empower").format({
			"power": power
		}) + "\n"
	elif power == 0:
		msg += tr("stranger.bagman.description.neutral") + "\n"
	else:
		msg += tr("stranger.bagman.description.weaken").format({
			"power": -power
		}) + "\n"
	
	if power > -3:
		msg += tr("stranger.bagman.description.prompt").format({
			"cost": cost
		})
	
	return "\"" + msg.strip_edges() + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
