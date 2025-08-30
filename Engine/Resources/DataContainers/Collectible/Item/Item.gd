@tool
extends Collectible
class_name Item

## An item in the player's inventory.

# ==============================================================================
## The various types of items available.
#enum Type {
	#INVALID = -1, ## Used when an item's type cannot be retrieved (e.g. when it has no data).
	#PASSIVE, ## An item that has passive effects that may repeatedly occur.
	#CONSUMABLE, ## A single-use item that takes effect once, when the player uses it.
	#MAGIC, ## An item that can be repeatedly used by the player, taking mana each time.
	#LEGENDARY, ## Similar to a passive item, but more powerful. Only a single legendary item can be in the inventory at a time.
	#OMEN, ## Similar to a passive item, but provides a negative effect.
	#MAX ## Constant used internally for the total number of item types.
#}
# ==============================================================================
#const TYPE_COLORS: Dictionary[Type, Color] = {
	#Type.INVALID: Color.RED,
	#Type.PASSIVE: Color.TRANSPARENT,
	#Type.CONSUMABLE: 0x14a464ff,
	#Type.MAGIC: 0x2a6eb0ff,
	#Type.OMEN: 0xbc3838ff,
	#Type.LEGENDARY: 0xb3871aff,
	#Type.MAX: Color.BLUE
#}
# ==============================================================================
@export var data: ItemData = null :
	set(value):
		data = value
		clear_texture_cache()
		emit_changed()

@export var _current_mana := 0 : set = set_mana, get = get_mana
# ==============================================================================
var _overrides: Dictionary[String, Variant] = {}
# ==============================================================================
signal cleared()
# ==============================================================================

#region internals

@warning_ignore("shadowed_variable")
func _init(data: ItemData = null) -> void:
	self.data = data


func _get_texture() -> Texture2D:
	return data.icon if data else null


func _get_annotation_text() -> String:
	if not has_mana():
		return ""
	
	return "%s\n[%d/%d %s]\n[color=gray]%s[/color]" % [
		get_annotation_title(),
		get_mana(),
		get_max_mana(),
		tr("MANA"),
		get_annotation_subtext()
	]


func _get_annotation_title() -> String:
	var item_name := get_item_name()
	if item_name.is_empty():
		return ""
	
	return "[color=#" + get_texture_bg_color().to_html(false) + "]" + tr(item_name).to_upper() + "[/color]"


func _get_annotation_subtext() -> String:
	var description := get_description()
	if description.is_empty():
		return ""
	
	return tr(description) if data else ""


func _get_texture_bg_color() -> Color:
	return Color.RED # used as invalid color


func _is_blinking() -> bool:
	return is_charged()


func _has_progress_bar() -> bool:
	return has_mana() and is_active()


func _get_progress() -> int:
	return get_mana()


func _get_max_progress() -> int:
	return get_max_mana()


func _post() -> void:
	#if get_type() == Type.CONSUMABLE:
		#clear()
		#return
	
	if has_mana():
		clear_mana()


func _to_string() -> String:
	var item_name := ""
	if "name" in _overrides:
		item_name = _overrides.name
	elif not data:
		return "<Item#null>"
	else:
		item_name = data.name
	
	return "<Item#%s>" % item_name


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	for override in _overrides:
		props.append({
			"name": override,
			"type": typeof(_overrides[override]),
			"usage": PROPERTY_USAGE_STORAGE
		})
	return props


func _get(property: StringName) -> Variant:
	if property in _overrides:
		return _overrides[property]
	return null


func _set(property: StringName, value: Variant) -> bool:
	if (ItemData as Script).get_script_property_list().any(func(prop: Dictionary) -> bool: return prop.name == property):
		_overrides[property] = value
		return true
	
	return false

#endregion

#region notifications

## Notifies this item that it has been added to the inventory. This method will
## first initialize the item and then call [method _inventory_add].
#func notify_inventory_added() -> void:
	#_in_inventory = true
	#_inventory_add()


## Virtual method to add custom events when the item is added to the inventory.
## [br][br]This method is called every time the item is added to the inventory,
## i.e. every time the inventory gets reloaded, or directly before the item is gained.
## See also [method _gain].
#func _inventory_add() -> void:
	#pass


## Notifies this item that it has been removed from the inventory. This method will
## first uninitialize the item and then call [method _inventory_remove].
#func notify_inventory_removed() -> void:
	#_in_inventory = false
	#_inventory_remove()


## Virtual method to add custom events when the item is removed from the inventory.
## [br][br]This method is called every time the item is removed from the inventory,
## i.e. every time the inventory gets removed from the scene tree, or directly after
## the item is lost. See also [method _lose].
#func _inventory_remove() -> void:
	#pass


## Notifies the item that it has been gained. This method will call [method _gain]
## to allow items to react to being gained.
func notify_gained() -> void:
	charge()
	_gain()


## Virtual method to add custom events when the item is gained.
## [br][br]This method is usually called only once per item, directly after it is
## added to the inventory. However, in certain circumstances, one item can be gained
## again after being lost. See also [method _inventory_add].
func _gain() -> void:
	pass


## Notifies the item that it has been lost. This method will call [method _lose]
## to allow items to react to being lost.
func notify_lost() -> void:
	_lose()


## Virtual method to add custom events when the item is lost.
## [br][br]This method usually called no more than once per item, directly before
## it is removed from the inventory. However, in certain circumstances, one item
## can be gained again after being lost. See also [method _inventory_remove].
func _lose() -> void:
	pass

#endregion

#region usability

#func _can_use() -> bool:
	#if data.type == Type.CONSUMABLE:
		#return true
	#if has_mana() and is_charged():
		#return true
	#
	#return false


## Returns whether this item can recieve _mana (i.e. it uses mana and the maximum
## mana is not yet reached).
func can_recieve_mana() -> bool:
	return has_mana() and get_mana() < get_max_mana()


## Returns whether this item uses mana.
func has_mana() -> bool:
	return get_max_mana() != 0


## Returns whether this item is charged, i.e. it uses mana and is at its maximum mana.
func is_charged() -> bool:
	return has_mana() and get_mana() >= get_max_mana()


func _is_active() -> bool:
	return get_inventory() != null


## Fully charges this [Item]'s mana. Does nothing if the item does not have mana.
func charge() -> void:
	set_mana(get_max_mana())


## Sets this item's current mana to [code]mana[/code].
func set_mana(mana: int) -> void:
	_current_mana = mana
	emit_changed()


## Adds the given [code]mana[/code] to the current mana.
func gain_mana(mana: int) -> void:
	_current_mana = clampi(_current_mana + mana, 0, get_max_mana())
	emit_changed()

#endregion

## Constructs a new item from the given path.
static func from_path(path: String) -> Item:
	if path.is_relative_path():
		path = "res://Assets/items/".path_join(path)
	
	var item_data := load(path.get_basename() + ".tres")
	return item_data.create()


func add_override(property: String, value: Variant) -> void:
	_overrides[property] = value

#region utilities

func get_inventory() -> QuestInventory:
	var base := get_parent()
	while base != null and base is not QuestInventory:
		base = base.get_parent()
	return base


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_attributes() -> QuestPlayerAttributes:
	return get_quest().get_attributes()


func get_stage() -> Stage:
	return get_quest().get_current_stage().get_stage()


func get_stage_instance() -> StageInstance:
	return get_quest().get_current_stage()


func get_board() -> Board:
	return get_stage_instance().get_board()


## Removes this item from the inventory.
func clear() -> void:
	cleared.emit()


## Resets this item's current mana to zero.
func clear_mana() -> void:
	_current_mana = 0
	emit_changed()


## Transforms this item into another item.
func transform(new_item: Item) -> void:
	transform_item(self, new_item)


## Targets a [Cell]. Waits for the player to select a [Cell] and then return it.
## This method is a coroutine, so it should be called with [code]await[/code].
## See also [method target_cells].
func target_cell() -> CellData:
	return await get_quest().get_current_stage().get_scene().cast(self)


## Targets multiple [Cell]s. Waits for the player to select a [Cell] and then
## returns all [Cell]s within the given [code]radius[/code] of the selected cell.
func target_cells(radius: int) -> Array[CellData]:
	if not get_quest().has_current_stage():
		return []
	
	var origin := await get_quest().get_current_stage().get_scene().cast(self)
	
	if not origin:
		return []
	
	var cells: Array[CellData] = []
	var topleft := origin.get_position() - (radius - 1) * Vector2i.ONE
	for offset_y in radius * 2 - 1:
		var y := topleft.y + offset_y
		for offset_x in radius * 2 - 1:
			var x := topleft.x + offset_x
			var pos := Vector2i(x, y)
			var cell := get_quest().get_current_stage().get_cell(pos)
			if cell:
				cells.append(cell)
	
	return cells


func gain_item(item: Item) -> void:
	get_inventory().item_gain(item)


func lose_item(item: Item) -> void:
	get_inventory().item_lose(item)


func transform_item(old_item: Item, new_item: Item) -> void:
	get_inventory().item_transform(old_item, new_item)


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_inventory().get_item_count():
		items.append(get_inventory().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_stats().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_stats().life_lose(life, source)

#endregion

#region getters

func get_item_name() -> String:
	if "name" in _overrides:
		return _overrides.name
	return data.name if data else ""


func get_description() -> String:
	if "description" in _overrides:
		return _overrides.description
	return data.description if data else ""


#func get_type() -> Type:
	#if "type" in _overrides:
		#return _overrides.type
	#return data.type if data else Type.INVALID


func get_max_mana() -> int:
	if "mana" in _overrides:
		return _overrides.mana
	return data.mana if data else 0


func is_mana_enabled() -> bool:
	return get_max_mana() != 0


func get_mana() -> int:
	return _current_mana


func get_cost() -> int:
	if "cost" in _overrides:
		return _overrides.cost
	return data.cost if data else 0


func get_tags() -> Array[String]:
	if "tags" in _overrides:
		return _overrides.tags
	return data.tags if data else []


func has_tag(tag: String) -> bool:
	return tag in get_tags()

#endregion
