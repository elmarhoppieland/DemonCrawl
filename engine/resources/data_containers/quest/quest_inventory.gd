@tool
extends Node
class_name QuestInventory

# ==============================================================================
#signal item_added(item: Item)
#signal item_removed(item: Item)
#signal item_transformed(old_item: Item, new_item: Item)

signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func _init() -> void:
	name = "Inventory"
	
	child_entered_tree.connect(func(child: Item) -> void:
		child.cleared.connect(item_lose.bind(child))
	)
	child_exiting_tree.connect(func(child: Item) -> void:
		child.cleared.disconnect(item_lose.bind(child))
	)


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	items.assign(get_children())
	return items


func get_item_count() -> int:
	return get_child_count()


func get_item(index: int) -> Item:
	if index < -get_item_count() or index >= get_item_count():
		return null
	
	return get_child(index)


func item_gain(item: Item) -> void:
	add_child(item)
	emit_changed()
	item.notify_gained()


func item_lose(item: Item) -> void:
	item.queue_free()
	remove_child(item)
	emit_changed()
	item.notify_lost()


func item_transform(old_item: Item, new_item: Item) -> void:
	if not has_item(old_item):
		Debug.log_error("Attempted to transform an item (%s) into another item (%s), but the original item is not in the inventory. Aborting..." % [old_item.get_name(), new_item.get_name()])
		return
	
	old_item.add_sibling(new_item)
	remove_child(old_item)
	old_item.notify_lost()
	new_item.notify_gained()
	
	old_item.queue_free()


func has_item(item: Item) -> bool:
	return item in get_children()


func has_item_data(item_data: ItemData) -> bool:
	return get_items().any(func(item: Item) -> bool:
		return item.data == item_data
	)


func mana_gain(mana: int, source: Object) -> void:
	mana = EffectManager.propagate_mutable(get_effects().gain_mana, 0, mana, source)
	
	var mana_items: Array[Item] = []
	mana_items.assign(get_items().filter(func(item: Item) -> bool: return item.can_recieve_mana()))
	
	if mana_items.is_empty():
		return
	
	for i in mana:
		mana_items.pick_random().gain_mana(1)
	
	EffectManager.propagate(get_effects().mana_gained, [mana, source])


func get_random_item() -> Item:
	return get_items().pick_random()


func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	for item in get_items():
		input = item.get_guaranteed_objects(input)
	return input

func is_empty() -> bool:
	return get_item_count() == 0


func get_effects() -> InventoryEffects:
	return get_quest().get_event_bus(InventoryEffects)


class InventoryEffects extends EventBus:
	signal gain_mana(mana: int, source: Object)
	signal mana_gained(mana: int, source: Object)
