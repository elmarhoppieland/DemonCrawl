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

func _ready() -> void:
	Effects.Signals.stage_leave.connect(_stage_leave)
	Effects.Signals.item_use.connect(_item_use)


func _spawn() -> void:
	cost = randi_range(5, 15)
	extra_fee = randi_range(10, 20)
	lives = randi_range(1, 3)


func _reset() -> void:
	Effects.Signals.stage_leave.disconnect(_stage_leave)
	Effects.Signals.item_use.disconnect(_item_use)


func _stage_leave() -> void:
	Quest.get_current().get_stats().lose_coins(extra_fee * purchase_count, self)


func _item_use(item: Item) -> void:
	if item is Apple:
		flee()


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_DOCTOR_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	Toasts.add_toast(tr("STRANGER_DOCTOR_INTERACT"), get_source())
	
	purchase_count += 1
	Quest.get_current().get_stats().life_restore(lives, self)


func _get_annotation_title() -> String:
	return tr("STRANGER_DOCTOR").to_upper()


func _get_annotation_subtext() -> String:
	if purchase_count == 0:
		return "\"" + Translator.translate("STRANGER_DOCTOR_DESCRIPTION", lives).format({
			"cost": cost,
			"fee": extra_fee,
			"lives": lives
		}) + "\""
	
	return "\"" + Translator.translate("STRANGER_DOCTOR_DESCRIPTION_EXTRA", lives).format({
		"cost": cost,
		"fee": extra_fee * purchase_count,
		"lives": lives,
		"new_fee": extra_fee * (purchase_count + 1)
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
