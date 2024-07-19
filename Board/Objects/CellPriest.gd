extends CellObject
class_name CellPriest

# ==============================================================================
var price := 0
# ==============================================================================

func interact() -> void:
	super()
	
	if Stats.coins < price:
		return
	
	Stats.spend_coins(price, self)
	
	var options := Inventory.items.filter(func(item: Item) -> bool: return item.data.type == Item.Type.OMEN)
	if options.is_empty():
		return
	Inventory.remove_item(options[RNG.randi() % options.size()])
	
	if PlayerStats.morality < 0:
		PlayerStats.morality = 0


func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = preload("res://Assets/sprites/priest.png")
	return texture


func get_animation_delta() -> float:
	return 0.52


func spawn() -> void:
	price = RNG.randi_range(15, 30) # TODO: research price range


func get_tooltip_text() -> String:
	return tr("STRANGER_PRIEST").to_upper()


func get_tooltip_subtext() -> String:
	return "\"" + tr("STRANGER_PRIEST_MESSAGE").format({
		"price": price
	}) + "\""
