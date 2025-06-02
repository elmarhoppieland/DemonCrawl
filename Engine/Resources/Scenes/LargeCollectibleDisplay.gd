@tool
extends MarginContainer
class_name LargeCollectibleDisplay

# ==============================================================================
@export var offer_price := -1 :
	set(value):
		offer_price = value
		
		if not is_node_ready():
			await ready
		
		if offer_price < 0:
			_coin_value.hide()
			return
		_coin_value.show()
		
		_coin_value.coin_value = offer_price
@export var show_focus := true

@export var texture: Texture2D :
	set(value):
		texture = value
		
		if not is_node_ready():
			await ready
		
		_collectible_display.texture = value

@export_group("Description Override", "description_")
@export_multiline var description_text := "" :
	set(value):
		description_text = value
		
		if not is_node_ready():
			await ready
		
		_collectible_display.description_text = value
@export_multiline var description_subtext := "" :
	set(value):
		description_subtext = value
		
		if not is_node_ready():
			await ready
		
		_collectible_display.description_subtext = value
# ==============================================================================
var collectible: Collectible :
	set(value):
		texture = value
	get:
		return texture if texture is Collectible else null
# ==============================================================================
@onready var _collectible_container: MarginContainer = %CollectibleContainer
@onready var _collectible_display: CollectibleDisplay = %CollectibleDisplay
@onready var _coin_value: CoinValue = %CoinValue
# ==============================================================================
signal interacted()
# ==============================================================================

func interact() -> void:
	Focus.move_to(_collectible_container)
	interacted.emit()


## Creates a new instance of the scene.
@warning_ignore("shadowed_variable")
static func create(texture: Texture2D) -> LargeCollectibleDisplay:
	var instance: LargeCollectibleDisplay = load("res://Engine/Resources/Scenes/LargeCollectibleDisplay.tscn").instantiate()
	instance.texture = texture
	return instance


func _on_collectible_display_interacted() -> void:
	if show_focus:
		interact()
