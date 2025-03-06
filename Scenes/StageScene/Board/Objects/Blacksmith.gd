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
@export var passed_turns := -1
# ==============================================================================

func _ready() -> void:
	Effects.Signals.turn.connect(func() -> void:
		if get_cell():
			_turn()
	)


func _spawn() -> void:
	type = Type.values().pick_random()
	cost = randi_range(10, 20)
	turns = randi_range(5, 15)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_BLACKSMITH_FAIL"), IconManager.get_icon_data("Blacksmith/Frame0").create_texture())
		return
	
	passed_turns = 0


func _get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.atlas = get_theme_icon("stranger_blacksmith")
	texture.size = Cell.CELL_SIZE
	return texture


func _get_annotation_title() -> String:
	return tr("STRANGER_BLACKSMITH").to_upper()


func _get_annotation_subtext() -> String:
	if passed_turns < 0:
		return "\"" + tr("STRANGER_BLACKSMITH_DESCRIPTION").format({
			"type": tr("ARMOR_TYPE_" + Type.find_key(type)),
			"cost": cost,
			"turns": turns
		}) + "\""
	
	return "\"" + tr("STRANGER_BLACKSMITH_BUSY") + "\"\n" + tr("STRANGER_BLACKSMITH_PROGRESS").format({
		"passed_turns": passed_turns,
		"turns": turns
	})


func _animate(time: float) -> void:
	get_texture().animate(1.0, time)


func _turn() -> void:
	if passed_turns < 0:
		return
	
	passed_turns += 1
	
	if passed_turns >= turns:
		var item := ItemDB.create_filter().filter_tag(TAGS[type]).set_min_cost(1).get_random_item()
		Quest.get_current().get_inventory().item_gain(item)
		passed_turns = -1
