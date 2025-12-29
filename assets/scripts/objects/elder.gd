@tool
extends Stranger
class_name Elder

# ==============================================================================
@export var cost := -1
# ==============================================================================

func _get_name_id() -> String:
	return "object.elder"


static func _can_spawn() -> bool:
	return Quest.get_current().get_mastery() != null


func _spawn() -> void:
	cost = randi_range(10, 20)


func _interact() -> void:
	if get_quest().get_stats().coins < cost:
		var handled := handle_fail()
		if not handled:
			Toasts.add_toast(tr("stranger.elder.fail"), get_source())
		return
	
	get_quest().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	get_quest().get_mastery().activate_ability()
	cost *= 2


func _get_annotation_title() -> String:
	return tr("stranger.elder").to_upper()


func _get_annotation_subtext() -> String:
	var subtext := "\"" + tr("stranger.elder.description").format({
		"cost": cost
	})
	if get_quest().get_mastery():
		subtext += "\"\n(" + get_quest().get_mastery().get_ability_description() + ")"
	return subtext


func _can_afford() -> bool:
	return get_quest().get_stats().coins >= cost
