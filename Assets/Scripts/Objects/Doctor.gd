@tool
extends Stranger
class_name Doctor

# ==============================================================================
const Apple := preload("res://Assets/items/Apple.gd")
# ==============================================================================
@export var cost := -1
@export var extra_fee := -1
@export var lives := -1

@export var purchase_count := 0
# ==============================================================================

func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().exited.connect(_stage_leave)
	get_quest().get_inventory().get_effects().item_use.connect(_item_use)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().exited.disconnect(_stage_leave)
	get_quest().get_inventory().get_effects().item_use.disconnect(_item_use)


func _spawn() -> void:
	cost = randi_range(5, 15)
	extra_fee = randi_range(10, 20)
	lives = randi_range(1, 3)


func _stage_leave() -> void:
	Quest.get_current().get_stats().lose_coins(extra_fee * purchase_count, self)


func _item_use(item: Item) -> void:
	if item is Apple:
		flee()


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("stranger.doctor.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	Toasts.add_toast(tr("stranger.doctor.interact"), get_source())
	
	purchase_count += 1
	Quest.get_current().get_stats().life_restore(lives, self)


func _get_annotation_title() -> String:
	return tr("stranger.doctor").to_upper()


func _get_annotation_subtext() -> String:
	if purchase_count == 0:
		return "\"" + tr_n("stranger.doctor.description", "stranger.doctor.description.plural", lives).format({
			"cost": cost,
			"fee": extra_fee,
			"lives": lives
		}) + "\""
	
	return "\"" + tr_n("stranger.doctor.description.extra", "stranger.doctor.description.extra.plural", lives).format({
		"cost": cost,
		"fee": extra_fee * purchase_count,
		"lives": lives,
		"new_fee": extra_fee * (purchase_count + 1)
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
