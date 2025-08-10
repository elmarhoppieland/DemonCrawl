@tool
extends Node
class_name QuestInventory

# ==============================================================================
#@export var items: Array[Item] = [] :
	#set(value):
		#for i in maxi(value.size(), items.size()):
			#if items.size() <= i:
				#item_added.emit(value[i])
			#elif value.size() <= i:
				#item_removed.emit(items[i])
			#elif items[i].get_script() != value[i].get_script():
				#item_transformed.emit(items[i], value[i])
			#
			#if i < value.size():
				#value[i].cleared.connect(item_lose.bind(value[i]))
				#value[i].set_quest(get_quest())
		#
		#items = value
		#emit_changed()
# ==============================================================================
var _effects := InventoryEffects.new() : get = get_effects
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
	
	item.cleared.connect(item_lose.bind(item))


func item_lose(item: Item) -> void:
	remove_child(item)
	item.queue_free()
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
	
	new_item.cleared.connect(item_lose.bind(new_item))
	
	old_item.queue_free()


func has_item(item: Item) -> bool:
	return item in get_children()


func has_item_data(item_data: ItemData) -> bool:
	return get_items().any(func(item: Item) -> bool:
		return item.data == item_data
	)


func mana_gain(mana: int, source: Object) -> void:
	mana = EffectManager.propagate(get_effects().gain_mana, [mana, source], 0)
	
	var mana_items: Array[Item] = []
	mana_items.assign(get_items().filter(func(item: Item) -> bool: return item.can_recieve_mana()))
	
	if mana_items.is_empty():
		return
	
	for i in mana:
		mana_items.pick_random().gain_mana(1)
	
	EffectManager.propagate(get_effects().mana_gained, [mana, source])


func get_random_item() -> Item:
	return get_items().pick_random()


func is_empty() -> bool:
	return get_item_count() == 0


func get_effects() -> InventoryEffects:
	return _effects


class InventoryEffects:
	@warning_ignore("unused_signal") signal item_use(item: Item)
	@warning_ignore("unused_signal") signal gain_mana(mana: int, source: Object)
	@warning_ignore("unused_signal") signal mana_gained(mana: int, source: Object)
