@tool
extends Stranger
class_name Blacksmith

# ==============================================================================
enum Type {
	HEAD,
	BODY,
	LEG
}
# ==============================================================================
const TAGS := {
	Type.HEAD: "armor/head",
	Type.BODY: "armor/body",
	Type.LEG: "armor/leg"
}
# ==============================================================================
@export var type := Type.HEAD
@export var cost := -1
@export var turns := -1
@export var passed_turns := -1 # this is -1 if the blacksmith isn't busy
# ==============================================================================

func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.connect(_turn)


func _spawn() -> void:
	type = Type.values().pick_random()
	cost = randi_range(10, 20)
	turns = randi_range(5, 15)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.disconnect(_turn)


func _interact() -> void:
	if passed_turns >= 0:
		return
	
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("stranger.blacksmith.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	activate()


func _activate() -> void:
	if passed_turns >= 0:
		return
	
	passed_turns = 0


func _get_annotation_title() -> String:
	return tr("stranger.blacksmith").to_upper()


func _get_annotation_subtext() -> String:
	if passed_turns < 0:
		return "\"" + tr("stranger.blacksmith.description").format({
			"type": tr("generic.armor." + Type.find_key(type).to_lower()),
			"cost": cost,
			"turns": turns
		}) + "\""
	
	return "\"" + tr("stranger.blacksmith.busy") + "\"\n" + tr("stranger.blacksmith.progress").format({
		"passed_turns": passed_turns,
		"turns": turns
	})


func _turn() -> void:
	if not get_cell():
		return
	if passed_turns < 0:
		return
	
	passed_turns += 1
	
	if passed_turns >= turns:
		var item := get_quest().get_item_pool().create_filter().filter_tag(TAGS[type]).set_min_cost(1).get_random_item()
		get_inventory().item_gain(item.create())
		passed_turns = -1


func _can_afford() -> bool:
	return get_stats().coins >= cost
