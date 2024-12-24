extends Resource
class_name QuestInstance

# ==============================================================================
@export var selected_stage_idx := 0 : ## The index of the selected [Stage].
	set(value):
		selected_stage_idx = value
		emit_changed()

@export var _items: Array[Item] = []

@export var _quest: Quest : set = set_quest, get = get_quest

@export_group("Statbar")
@export var max_life := 0 :
	set(value):
		max_life = value
		emit_changed()
@export var life := 0 :
	set(value):
		life = value
		emit_changed()
@export var revives := 0 :
	set(value):
		revives = value
		emit_changed()
@export var defense := 0 :
	set(value):
		defense = value
		emit_changed()
@export var coins := 0 :
	set(value):
		coins = value
		emit_changed()

@export_group("Global Stats")
@export var score := 0 :
	set(value):
		score = value
		emit_changed()
@export var cells_opened_since_mistake := 0 :
	set(value):
		cells_opened_since_mistake = value
		emit_changed()
@export var morality := 0 :
	set(value):
		morality = value
		emit_changed()
@export var chests_opened := 0 :
	set(value):
		chests_opened = value
		emit_changed()
@export var monsters_killed := 0 :
	set(value):
		monsters_killed = value
		emit_changed()
@export_subgroup("Chain", "_chain_")
@export var chain_value := 0 :
	set(value):
		chain_value = value
		emit_changed()
@export var chain_length := 0 :
	set(value):
		chain_length = value
		emit_changed()
# ==============================================================================
signal inventory_changed()
signal inventory_item_added(item: Item)
signal inventory_item_removed(item: Item)
signal inventory_item_transformed(old_item: Item, new_item: Item)
# ==============================================================================

## Returns the currently selected [Stage].
func get_selected_stage() -> Stage:
	return get_quest().stages[selected_stage_idx]


## Restores [code]life[/code] lives, without exceeding the max lives.
@warning_ignore("shadowed_variable")
func life_restore(life: int, source: Object) -> void:
	if life < 0:
		return
	
	self.life = mini(self.life + Effects.restore_life(life, source), max_life)


## Loses [code]life[/code] lives.
@warning_ignore("shadowed_variable")
func life_lose(life: int, source: Object) -> void:
	if life < 0:
		return
	
	self.life -= Effects.lose_life(life, source)
	
	if Stage.has_current():
		Stage.get_current().get_scene().get_background().flash_red()
	
	if self.life < 0:
		die()


## Causes the player to immediately die. If the player has any revives, one will
## be used to revive the player at maximum life. Otherwise, the player loses the quest.
## See also [method lose].
func die() -> void:
	if revives > 0:
		revives -= 1
		life = max_life
		Toasts.add_toast("You now have %d revives..." % revives, IconManager.get_icon_data("icons/revive").create_texture())
		return
	
	lose()


## Causes the player to immediately lose the quest. If the player has any revives,
## they will not be used to revive the player. See also [method die].
func lose() -> void:
	pass # TODO


func _set(property: StringName, value: Variant) -> bool:
	if not (Effects as GDScript).has_method("change_" + property):
		return false
	for method in (Effects as GDScript).get_script_method_list():
		if method.name == "change_" + property:
			if method.args.size() - method.default_args.size() != 1:
				return false
			break
	
	value = (Effects as GDScript).call("change_" + property, value)
	emit_changed()
	return false


func set_quest(quest: Quest) -> void:
	if get_quest() and get_quest().changed.is_connected(emit_changed):
		get_quest().changed.disconnect(emit_changed)
	
	_quest = quest
	
	if quest and not quest.changed.is_connected(emit_changed):
		quest.changed.connect(emit_changed)


func get_quest() -> Quest:
	return _quest


func get_item_count() -> int:
	return _items.size()


func get_item(idx: int) -> Item:
	return _items[idx]


func item_gain(item: Item) -> void:
	_items.append(item)
	item.notify_inventory_added()
	inventory_item_added.emit(item)
	inventory_changed.emit()
	item.notify_gained()


func item_lose(item: Item) -> void:
	_items.erase(item)
	item.notify_inventory_removed()
	inventory_item_removed.emit(item)
	inventory_changed.emit()
	item.notify_lost()


func item_transform(old_item: Item, new_item: Item) -> void:
	assert(old_item in _items)
	var idx := _items.find(old_item)
	_items[idx] = new_item
	
	old_item.notify_inventory_removed()
	new_item.notify_inventory_added()
	inventory_changed.emit()
	inventory_item_transformed.emit(old_item, new_item)
	old_item.notify_lost()
	new_item.notify_gained()


func item_has(item: Item, exact: bool = false) -> bool:
	if exact:
		return item in _items
	
	for i in _items:
		if i.get_script() == item.get_script():
			return true
	
	return false


@warning_ignore("shadowed_variable")
func spend_coins(coins: int, destination: Object) -> void:
	self.coins -= Effects.spend_coins(coins, destination)


func mana_gain(mana: int, source: Object) -> void:
	mana = Effects.gain_mana(mana, source)
	
	var rng := RandomNumberGenerator.new()
	rng.seed = rng.randi()
	
	var mana_items: Array[Item] = []
	mana_items.assign(_items.filter(func(item: Item) -> bool: return item.can_recieve_mana()))
	
	if mana_items.is_empty():
		return
	
	for i in mana:
		mana_items[rng.randi() % mana_items.size()].gain_mana(1)


func damage(amount: int, source: Object) -> void:
	amount = Effects.damage(amount, source)
	if amount > 0:
		life_lose(amount, source)
	if Stage.has_current() and Stage.get_current().has_scene():
		Stage.get_current().get_board().get_camera().shake()
