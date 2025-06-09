@tool
extends Stranger
class_name Scribe

# ==============================================================================
enum Type {
	INCREASE,
	COPY,
	REACTIVATE
}
# ==============================================================================
@export var cost := -1
@export var type := Type.INCREASE
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(20, 40)
	type = Type.values().pick_random()


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_SCRIBE_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	match type:
		Type.INCREASE:
			for i in Codex.get_heirloom_slots():
				var data := Codex.get_heirloom_data(i)
				if data:
					data.count = mini(data.count + 1, 10)
		Type.COPY:
			for i in Codex.get_heirloom_slots():
				Codex.set_heirloom(i, get_inventory().get_item(i))
		Type.REACTIVATE:
			Quest.get_current().heirlooms_active = true


func _get_annotation_title() -> String:
	return tr("STRANGER_SCRIBE").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_SCRIBE_%s_DESCRIPTION" % Type.find_key(type)).format({
		"cost": cost,
		"slot_count": Codex.get_heirloom_slots()
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
