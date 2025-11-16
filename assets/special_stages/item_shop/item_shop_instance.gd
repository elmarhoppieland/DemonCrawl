@tool
extends StageInstanceBase
class_name ItemShopInstance

# ==============================================================================
const SCENE := preload("res://assets/special_stages/item_shop/item_shop.tscn")
# ==============================================================================

func _ready() -> void:
	if was_reloaded():
		return
	
	var offer_count: int = EffectManager.propagate_mutable((get_quest().get_event_bus(ItemShopEffects) as ItemShopEffects).get_offer_count, 1, self, 3)
	var items := get_quest().get_item_pool().create_filter()\
		.set_max_cost(maxi(get_quest().get_stats().coins, 10))\
		.set_min_cost(1)\
		.get_random_item_set(offer_count)
	
	for data in items:
		var item := data.create()
		var offer := ItemShopOffer.new()
		offer.add_child(item)
		offer.cost = maxi(floori(item.get_cost() * randf_range(0.7, 1.3)), 1)
		get_offers_parent().add_child(offer)


func _create_scene() -> Node:
	var scene: ItemShopScene = SCENE.instantiate()
	scene.instance = self
	return scene


## Returns this shop's items.
func get_offers() -> Array[ItemShopOffer]:
	var items: Array[ItemShopOffer] = []
	items.assign(get_offers_parent().get_children())
	return items


## Returns the parent [Node] of the offers.
func get_offers_parent() -> Node:
	if not has_node("Offers"):
		var offers := Node.new()
		offers.name = "Offers"
		add_child(offers)
	return get_node("Offers")


## Purchases the given [Item].
func purchase(offer_idx: int) -> void:
	var offer: ItemShopOffer = get_offers()[offer_idx]
	
	if get_quest().get_stats().coins < offer.cost:
		return
	get_quest().get_stats().spend_coins(offer.cost, self)
	
	var item := offer.get_item()
	offer.remove_child(item)
	get_quest().get_inventory().item_gain(item)

@warning_ignore_start("unused_signal")

class ItemShopEffects extends EventBus:
	signal get_offer_count(shop: ItemShopInstance, count: int)

@warning_ignore_restore("unused_signal")

class ItemShopOffer extends Node:
	@export var cost := -1
	
	func get_item() -> Item:
		for child in get_children():
			if child is Item:
				return child
		return null
