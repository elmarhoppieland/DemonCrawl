extends CellObject
class_name CellBlacksmith

# ==============================================================================
enum ArmorType {
	HEAD,
	BODY,
	LEG
}
# ==============================================================================
var turns := 0
var cost := 0
var type := ArmorType.HEAD

var passed_turns := -1
# ==============================================================================

func spawn() -> void:
	type = RNG.randi() % ArmorType.size() as ArmorType
	turns = RNG.randi_range(7, 15)
	cost = RNG.randi_range(10, 20)


func interact() -> void:
	if Stats.coins < cost or passed_turns >= 0:
		return
	
	Stats.spend_coins(cost, self)
	
	passed_turns = 0
	
	var lambda := func turn(l: Callable) -> void:
		passed_turns += 1
		if passed_turns >= turns:
			EffectManager.disconnect_effect(l, &"turn")
			passed_turns = -1
			
			Inventory.gain_item(ItemDB.create_filter().filter_tag(ArmorType.find_key(type).capitalize().to_lower() + "_armor").get_random_item())
	
	lambda.bind(lambda)
	
	EffectManager.connect_effect(lambda, EffectManager.Priority.STAGE_OBJECT, 0, false, false, &"turn") # TODO: determine subpriority


func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = preload("res://Assets/sprites/strangers/blacksmith.png")
	return texture


func get_animation_delta() -> float:
	return 0.5


func get_tooltip_text() -> String:
	return tr("STRANGER_BLACKSMITH")


func get_tooltip_subtext() -> String:
	if passed_turns >= 0:
		return "\"" + tr("STRANGER_BLACKSMITH_MESSAGE_BUSY") + "\"\n[" + str(passed_turns) + "/" + str(turns) + "]"
	
	return "\"" + tr("STRANGER_BLACKSMITH_MESSAGE").format({
		"turns": turns,
		"cost": cost,
		"type": ArmorType.find_key(type).capitalize().to_lower()
	}) + "\""
