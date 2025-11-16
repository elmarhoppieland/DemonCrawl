@tool
extends StageInstanceBase
class_name BazaarInstance

# ==============================================================================

func _ready() -> void:
	if was_reloaded():
		return
	
	var buy_offer := BuyItemOffer.new()
	add_child(buy_offer)
	buy_offer.refresh()
	
	var sell_offer := SellItemOffer.new()
	add_child(sell_offer)
	sell_offer.refresh()
	
	var trade_offer := TradeItemOffer.new()
	add_child(trade_offer)
	trade_offer.refresh()


func get_buy_offer() -> BuyItemOffer:
	for child in get_children():
		if child is BuyItemOffer:
			return child
	return null


func get_sell_offer() -> SellItemOffer:
	for child in get_children():
		if child is SellItemOffer:
			return child
	return null


func get_trade_offer() -> TradeItemOffer:
	for child in get_children():
		if child is TradeItemOffer:
			return child
	return null


func _create_scene() -> Node:
	var scene: BazaarScene = load("res://assets/special_stages/bazaar/bazaar_scene.tscn").instantiate()
	scene.instance = self
	return scene


@abstract
class ItemOfferBase extends ResourceNode:
	func get_item() -> Item:
		for child in get_children():
			if child is Item:
				return child
		return null
	
	func get_quest() -> Quest:
		var base := get_parent()
		while base != null and base is not Quest:
			base = base.get_parent()
		return base
	
	func get_bazaar() -> BazaarInstance:
		var base := get_parent()
		while base != null and base is not BazaarInstance:
			base = base.get_parent()
		return base
	
	func perform() -> void:
		_perform()
	
	@abstract func _perform() -> void
	
	func refresh() -> void:
		_refresh()
	
	@abstract func _refresh() -> void
	
	func can_afford() -> bool:
		return _can_afford()
	
	@abstract func _can_afford() -> bool


@abstract
class PricedItemOffer extends ItemOfferBase:
	@export var cost := 0 :
		set(value):
			cost = value
			emit_changed()


class BuyItemOffer extends PricedItemOffer:
	func _can_afford() -> bool:
		return get_quest().get_stats().can_afford(cost, self)
	
	func _perform() -> void:
		get_quest().get_stats().spend_coins(cost, self)
		
		var item := get_item()
		remove_child(item)
		get_quest().get_inventory().item_gain(item)
		
		refresh()
		
		var trade_offer := get_bazaar().get_trade_offer()
		if not trade_offer.get_item():
			trade_offer.refresh()
	
	func _refresh() -> void:
		if get_item():
			get_item().queue_free()
		
		var item := get_quest().get_item_pool().create_filter()\
			.set_max_cost(maxi(get_quest().get_stats().coins, 10))\
			.set_min_cost(1)\
			.get_random_item()
		
		cost = maxi(randi_range(floori(item.cost * 0.7), floori(item.cost * 1.3)), 1) 
		add_child(item.create())


class SellItemOffer extends PricedItemOffer:
	func _can_afford() -> bool:
		return get_item() and get_quest().get_inventory().has_item_data(get_item().data)
	
	func _perform() -> void:
		var sell_item_data := get_item().data
		for item in get_quest().get_inventory().get_items():
			if item.data == sell_item_data:
				get_quest().get_inventory().item_lose(item)
				get_quest().get_stats().gain_coins(cost, self)
				break
		
		refresh()
		
		var trade_offer := get_bazaar().get_trade_offer()
		if not trade_offer.get_item() or trade_offer.cost == sell_item_data:
			trade_offer.refresh()
	
	func _refresh() -> void:
		if get_item():
			get_item().queue_free()
		
		if get_quest().get_inventory().is_empty():
			await get_quest().get_inventory().child_entered_tree
		
		var item := get_quest().get_inventory().get_random_item().data
		cost = maxi(floori(item.cost * 0.7), 1)
		add_child(item.create())


class TradeItemOffer extends ItemOfferBase:
	@export var cost: ItemData :
		set(value):
			cost = value
			emit_changed()
	@export var self_refreshed := false
	
	func _can_afford() -> bool:
		return get_quest().get_inventory().has_item_data(cost)
	
	func _perform() -> void:
		for item in get_quest().get_inventory().get_items():
			if item.data == cost:
				get_quest().get_inventory().item_lose(item)
				item = get_item()
				remove_child(item)
				get_quest().get_inventory().item_gain(item)
				break
		
		var sell_offer := get_bazaar().get_sell_offer()
		if sell_offer.get_item().data == cost:
			sell_offer.refresh()
		
		if not self_refreshed:
			refresh()
			self_refreshed = true
	
	func _refresh() -> void:
		self_refreshed = false
		
		if get_item():
			get_item().queue_free()
		
		if get_quest().get_inventory().is_empty():
			return
		
		cost = get_quest().get_inventory().get_random_item().data
		var item := get_quest().get_item_pool().create_filter()\
			.set_max_cost(floori(cost.cost * 1.3))\
			.set_min_cost(maxi(floori(cost.cost * 0.7), 1))\
			.get_random_item()
		add_child(item.create())
