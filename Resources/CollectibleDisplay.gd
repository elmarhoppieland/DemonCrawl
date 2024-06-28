@tool
extends MarginContainer
class_name CollectibleDisplay

# ==============================================================================
@export var offer_price := -1 :
	set(value):
		offer_price = value
		
		if not is_node_ready():
			await ready
		
		if offer_price < 0:
			coin_value.hide()
			return
		coin_value.show()
		
		coin_value.coin_value = offer_price
@export var show_focus := true :
	set(value):
		show_focus = value
		
		if not is_node_ready():
			await ready
		
		focus_grabber.enabled = value
# ==============================================================================
var collectible: Collectible :
	set(value):
		if collectible == value:
			return
		
		var previous := collectible
		
		collectible = value
		
		if not collectible:
			return
		
		if not is_node_ready():
			await ready
		
		if previous:
			previous.remove_node_from_tree()
		
		if collectible:
			collectible_node_parent.add_child(collectible.get_node())
# ==============================================================================
@onready var collectible_node_parent: MarginContainer = %CollectibleNodeParent
@onready var focus_grabber: FocusGrabber = %FocusGrabber
@onready var coin_value: CoinValue = %CoinValue
# ==============================================================================

## Removes the collectible node (created via [method Collectible.create_node])
## from the scene tree and returns the node. Does [b]not[/b] free the node.
func detach_collectible_node() -> MarginContainer:
	collectible.remove_node_from_tree(true)
	return collectible.node


## Creates a new instance of the scene.
static func create(_collectible: Collectible) -> CollectibleDisplay:
	var instance: CollectibleDisplay = ResourceLoader.load("res://Resources/CollectibleDisplay.tscn").instantiate()
	instance.collectible = _collectible
	return instance
