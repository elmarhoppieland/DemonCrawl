@tool
extends Collectible
class_name Item

## An item in the player's inventory.

# ==============================================================================
## The various types of items available.
enum Type {
	PASSIVE, ## An item that has passive effects that may repeatedly occur.
	CONSUMABLE, ## A single-use item that takes effect once, when the player uses it.
	MAGIC, ## An item that can be repeatedly used by the player, taking mana each time.
	LEGENDARY, ## Similar to a passive item, but more powerful. Only a single legendary item can be in the inventory at a time.
	OMEN, ## Similar to a passive item, but provides a negative effect.
	MAX ## Constant used internally for the total number of item types.
}
# ==============================================================================
const TYPE_COLORS := {
	Type.PASSIVE: Color.TRANSPARENT,
	Type.CONSUMABLE: Color("14a464"),
	Type.MAGIC: Color("2a6eb0"),
	Type.OMEN: Color("bc3838"),
	Type.LEGENDARY: Color("b3871a")
}
# ==============================================================================
@export var _name := "" : set = _set_name
@export_multiline var _description := ""
@export var _type := Type.PASSIVE : set = _set_type, get = get_type
@export var _mana := 0 : set = set_max_mana, get = get_max_mana
@export var _cost := 0 : get = get_cost
@export var _tags: PackedStringArray : get = get_tags
@export var _atlas_region := Rect2(0, 0, 16, 16) :
	set(value):
		_atlas_region = value
		emit_changed()
@export var _atlas: Texture2D = preload("res://Assets/Sprites/items.png") :
	set(value):
		_atlas = value
		emit_changed()
# ==============================================================================
var _current_mana := 0 : set = set_mana, get = get_mana
var _in_inventory := false
# ==============================================================================
signal cleared()
# ==============================================================================

#region internals

func _init() -> void:
	super()
	
	if _name.is_empty() and Engine.is_editor_hint():
		(func() -> void: _name = "ITEM_" + resource_path.get_file().get_basename().to_snake_case().to_upper()).call_deferred()


func _get_atlas() -> CompressedTexture2D:
	return _atlas


func _get_atlas_region() -> Rect2:
	return _atlas_region


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
	return "[color=#" + get_texture_bg_color().to_html(false) + "]" + tr(_name).to_upper() + "[/color]"


func _get_annotation_subtext() -> String:
	return tr(_description)


func _get_texture_bg_color() -> Color:
	return TYPE_COLORS.get(get_type(), Color.TRANSPARENT)


func _is_blinking() -> bool:
	return is_charged()


func _has_progress_bar() -> bool:
	return has_mana()


func _get_progress() -> int:
	return get_mana()


func _get_max_progress() -> int:
	return get_max_mana()


func _post() -> void:
	if get_type() == Type.CONSUMABLE:
		clear()
		return
	
	if has_mana():
		clear_mana()


func _export() -> Dictionary:
	var dict := {
		"path": get_path()
	}
	
	if _mana:
		dict._mana = _current_mana
	
	return dict


static func _import(value: Dictionary) -> Item:
	assert("path" in value)
	
	var item := Item.from_path(value.path)
	if "_mana" in value:
		item._current_mana = value._mana
	return item


func _to_string() -> String:
	return tr(get_name())


func _property_can_revert(property: StringName) -> bool:
	return get_script().get_script_property_list().any(func(prop: Dictionary): return prop.name == property)


func _property_get_revert(property: StringName) -> Variant:
	if property == &"_description":
		if _name.is_empty():
			return ""
		return _name.to_snake_case().to_upper() + "_DESCRIPTION"
	if property == &"_name":
		return "ITEM_" + resource_path.get_file().get_basename().to_snake_case().to_upper()
	if property == &"atlas":
		return preload("res://Assets/Sprites/items.png")
	
	return get_script().get_property_default_value(property)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_in_inventory", "_current_mana" when not Engine.is_editor_hint():
			property.usage |= PROPERTY_USAGE_STORAGE


func _set_name(name: String) -> void:
	if _description.is_empty() or _description == _name.to_snake_case().to_upper() + "_DESCRIPTION":
		if name.is_empty():
			_description = ""
		else:
			_description = name.to_snake_case().to_upper() + "_DESCRIPTION"
	_name = name
	resource_name = name
	emit_changed()


func _set_type(type: Type) -> void:
	_type = type
	emit_changed()


func set_max_mana(mana: int) -> void:
	_mana = mana
	emit_changed()

#endregion

#region notifications

## Notifies this item that it has been added to the inventory. This method will
## first initialize the item and then call [method _inventory_add].
func notify_inventory_added() -> void:
	_in_inventory = true
	EffectManager.register_object(self)
	_inventory_add()


## Virtual method to add custom events when the item is added to the inventory.
## [br][br]This method is called every time the item is added to the inventory,
## i.e. every time the inventory gets reloaded, or directly before the item is gained.
## See also [method _gain].
func _inventory_add() -> void:
	pass


## Notifies this item that it has been removed from the inventory. This method will
## first uninitialize the item and then call [method _inventory_remove].
func notify_inventory_removed() -> void:
	_in_inventory = false
	EffectManager.unregister_object(self)
	_inventory_remove()


## Virtual method to add custom events when the item is removed from the inventory.
## [br][br]This method is called every time the item is removed from the inventory,
## i.e. every time the inventory gets removed from the scene tree, or directly after
## the item is lost. See also [method _lose].
func _inventory_remove() -> void:
	pass


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

func _can_use() -> bool:
	if _type == Type.CONSUMABLE:
		return true
	if has_mana() and is_charged():
		return true
	
	return false


## Returns whether this item can recieve _mana (i.e. it uses mana and the maximum
## mana is not yet reached).
func can_recieve_mana() -> bool:
	return has_mana() and _current_mana < _mana


## Returns whether this item uses mana.
func has_mana() -> bool:
	return _mana != 0


## Returns whether this item is charged, i.e. it uses mana and is at its maximum mana.
func is_charged() -> bool:
	return has_mana() and _current_mana >= _mana


func _is_active() -> bool:
	return _in_inventory


## Fully charges this [Item]'s mana. Does nothing if the item does not have mana.
func charge() -> void:
	set_mana(get_max_mana())


## Sets this item's current mana to [code]mana[/code].
func set_mana(mana: int) -> void:
	mana = clampi(mana, 0, get_max_mana())
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
	
	return load(path.get_basename() + ".tres").duplicate()

#region utilities

func get_quest() -> Quest:
	return Quest.get_current()


func get_inventory() -> QuestInventory:
	return get_quest().get_inventory()


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_attributes() -> QuestPlayerAttributes:
	return get_quest().get_attributes()


func get_stage() -> Stage:
	return Stage.get_current()


func get_board() -> Board:
	return get_stage().get_board()


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
	return await Stage.get_current().get_instance().cast(self)


## Targets multiple [Cell]s. Waits for the player to select a [Cell] and then
## returns all [Cell]s within the given [code]radius[/code] of the selected cell.
func target_cells(radius: int) -> Array[CellData]:
	if not Stage.has_current():
		return []
	
	var origin := await Stage.get_current().get_scene().cast(self)
	
	if not origin:
		return []
	
	var cells: Array[CellData] = []
	var topleft := origin.get_board_position() - (radius - 1) * Vector2i.ONE
	for offset_y in radius * 2 - 1:
		var y := topleft.y + offset_y
		for offset_x in radius * 2 - 1:
			var x := topleft.x + offset_x
			var pos := Vector2i(x, y)
			var cell := Stage.get_current().get_instance().get_cell(pos)
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

func get_type() -> Type:
	return _type


func get_max_mana() -> int:
	return _mana


func is_mana_enabled() -> bool:
	return get_max_mana() != 0


func get_mana() -> int:
	if not Engine.is_editor_hint() and not resource_path.is_empty():
		return get_max_mana()
	return _current_mana


func get_cost() -> int:
	return _cost


func get_tags() -> PackedStringArray:
	return _tags


func has_tag(tag: String) -> bool:
	return tag in _tags

#endregion
