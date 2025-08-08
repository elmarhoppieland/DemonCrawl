@tool
extends Node
class_name QuestInventory

# ==============================================================================
@export var items: Array[Item] = [] :
	set(value):
		for i in maxi(value.size(), items.size()):
			if items.size() <= i:
				item_added.emit(value[i])
			elif value.size() <= i:
				item_removed.emit(items[i])
			elif items[i].get_script() != value[i].get_script():
				item_transformed.emit(items[i], value[i])
			
			if i < value.size():
				value[i].cleared.connect(item_lose.bind(value[i]))
				value[i].set_quest(get_quest())
		
		items = value
		emit_changed()
# ==============================================================================
var _effects := InventoryEffects.new() : get = get_effects
# ==============================================================================
signal item_added(item: Item)
signal item_removed(item: Item)
signal item_transformed(old_item: Item, new_item: Item)

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


func get_item_count() -> int:
	return items.size()


func get_item(index: int) -> Item:
	if index < -items.size() or index >= items.size():
		return null
	
	return items[index]


func item_gain(item: Item) -> void:
	if not item.resource_path.is_empty():
		item = item.duplicate()
	
	items.append(item)
	item.notify_inventory_added()
	item_added.emit(item)
	emit_changed()
	item.notify_gained()
	
	item.cleared.connect(item_lose.bind(item))


func item_lose(item: Item) -> void:
	items.erase(item)
	item.notify_inventory_removed()
	item_removed.emit(item)
	emit_changed()
	item.notify_lost()


func item_transform(old_item: Item, new_item: Item) -> void:
	if old_item not in items:
		Debug.log_error("Attempted to transform an item (%s) into another item (%s), but the original item is not in the inventory. Aborting..." % [old_item.get_name(), new_item.get_name()])
		return
	
	var idx := items.find(old_item)
	items[idx] = new_item
	
	old_item.notify_inventory_removed()
	new_item.notify_inventory_added()
	emit_changed()
	item_transformed.emit(old_item, new_item)
	old_item.notify_lost()
	new_item.notify_gained()
	
	new_item.cleared.connect(item_lose.bind(new_item))


func item_has(item: Item, exact: bool = false) -> bool:
	if exact:
		return item in items
	
	for i in items:
		if i.get_script() == item.get_script():
			return true
	
	return false


func mana_gain(mana: int, source: Object) -> void:
	mana = EffectManager.propagate(get_effects().mana_gained, [mana, source], 0)
	
	var mana_items: Array[Item] = []
	mana_items.assign(items.filter(func(item: Item) -> bool: return item.can_recieve_mana()))
	
	if mana_items.is_empty():
		return
	
	for i in mana:
		mana_items.pick_random().gain_mana(1)


func get_random_item() -> Item:
	return items.pick_random()


func item_lose_random() -> void:
	if items.is_empty():
		return
	
	item_lose(get_random_item())


func is_empty() -> bool:
	return items.is_empty()


func get_effects() -> InventoryEffects:
	return _effects


class InventoryEffects:
	@warning_ignore("unused_signal") signal item_use(item: Item)
	@warning_ignore("unused_signal") signal mana_gained(mana: int, source: Object)
