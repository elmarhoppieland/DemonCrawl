extends CellObject
class_name CellGambler

# ==============================================================================
var price := RNG.randi_range(5, 10) # TODO: research price range
var coins := 10
# ==============================================================================

func spawn() -> void:
	EffectManager.connect_effect(func turn() -> void:
		if RNG.randi() % 5 == 0:
			RNG.randi_range(1, 3)
	, EffectManager.Priority.STAGE_OBJECT, 0, true, false, &"turn")


func interact() -> void:
	super()
	
	if Stats.coins < price or empowerment <= -3:
		return
	
	Stats.spend_coins(price, self)
	
	empowerment -= 1


func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = preload("res://Assets/sprites/strangers/bagman.png")
	return texture


func get_animation_delta() -> float:
	return 0.5


func get_tooltip_text() -> String:
	return tr("STRANGER_BAGMAN").to_upper()


func get_tooltip_subtext() -> String:
	if empowerment > 0:
		return "\"" + tr("STRANGER_BAGMAN_MESSAGE").format({
			"empowerment": empowerment,
			"price": price
		}) + "\""
	
	if empowerment == 0:
		return "\"" + tr("STRANGER_BAGMAN_MESSAGE_NEUTRAL").format({
			"price": price
		}) + "\""
	
	return "\"" + tr("STRANGER_BAGMAN_MESSAGE_GOOD").format({
		"empowerment": -empowerment,
		"price": price
	}) + "\""
