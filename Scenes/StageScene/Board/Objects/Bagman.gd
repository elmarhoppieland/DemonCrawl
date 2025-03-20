@tool
extends Stranger
class_name Bagman

# ==============================================================================
@export var cost := -1
@export var power := 0
# ==============================================================================

func _ready() -> void:
	Effects.MutableSignals.damage.connect(func(amount: int, source: Object) -> int:
		if source is Monster:
			amount += power
		return maxi(0, amount)
	)


func _spawn() -> void:
	cost = randi_range(5, 10)
	power = randi_range(1, 3)


func _interact() -> void:
	if power <= -3:
		return
	
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_BAGMAN_FAIL"), IconManager.get_icon_data("Bagman/Frame0").create_texture())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	activate()


func _activate() -> void:
	power -= 1
	Toasts.add_toast(tr("STRANGER_BAGMAN_INTERACT"), IconManager.get_icon_data("Bagman/Frame0").create_texture())


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
