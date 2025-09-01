@tool
extends Stranger
class_name Elder

# ==============================================================================
@export var cost := -1
# ==============================================================================

static func _can_spawn() -> bool:
	return Quest.get_current().get_mastery() != null


func _spawn() -> void:
	cost = randi_range(10, 20)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("stranger.elder.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	Quest.get_current().get_mastery().activate_ability()
	cost *= 2


func _get_annotation_title() -> String:
	return tr("stranger.elder").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("stranger.elder.description").format({
		"cost": cost
	}) + "\"\n(" + Quest.get_current().get_mastery().get_ability_description() + ")"


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
