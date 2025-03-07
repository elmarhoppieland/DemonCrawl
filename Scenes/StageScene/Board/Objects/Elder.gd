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
		Toasts.add_toast(tr("STRANGER_ELDER_FAIL"), IconManager.get_icon_data("Elder/Frame0").create_texture())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	Quest.get_current().get_mastery().activate_ability()
	cost *= 2


func _get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.atlas = get_theme_icon("stranger_elder")
	texture.size = Cell.CELL_SIZE
	return texture


func _get_annotation_title() -> String:
	return tr("STRANGER_ELDER").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_ELDER_DESCRIPTION").format({
		"cost": cost
	}) + "\"\n(" + Quest.get_current().get_mastery().get_ability_description() + ")"


func _animate(time: float) -> void:
	get_texture().animate(1.0, time)
