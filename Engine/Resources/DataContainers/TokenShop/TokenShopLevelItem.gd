@tool
extends TokenShopItemBase
class_name TokenShopLevelItem

# ==============================================================================
var levels: Array[TokenShopItem] = []

var base := TokenShopItem.new() :
	get:
		if not base:
			base = TokenShopItem.new()
		return base
# ==============================================================================

func get_next_level() -> TokenShopItem:
	var idx := TokenShop.get_purchased_level(self)
	if idx >= levels.size():
		return levels[-1]
	return levels[idx]


func _purchase() -> void:
	get_next_level().notify_purchased()


func _reapply_reward(purchase_count: int) -> void:
	for i in purchase_count:
		levels[i].reapply_reward(1)


func _is_purchased() -> bool:
	return TokenShop.get_purchased_level(self) >= levels.size()


func _get_name() -> String:
	var level := TokenShop.get_purchased_level(self)
	if level < levels.size():
		return tr(get_next_level().get_display_name()) + " " + RomanNumeral.convert_to_roman(level + 1)
	return tr(get_next_level().get_display_name())


func _get_description() -> String:
	return get_next_level().get_description()


func _get_icon() -> Texture2D:
	return get_next_level().get_icon()


func _get_cost() -> int:
	return get_next_level().get_cost()


func _is_visible() -> bool:
	return get_next_level().is_visible()


func _is_locked() -> bool:
	return get_next_level().is_locked()


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	var found := false
	for property in base.get_property_list():
		if property.name == "TokenShopItem.gd":
			found = true
			continue
		if not property.usage & PROPERTY_USAGE_EDITOR:
			continue
		if not found:
			continue
		property.name = "Base/" + property.name
		properties.append(property)
	
	properties.append({
		"name": "level_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT,
		"class_name": "Levels,level_"
	})
	
	for i in levels.size():
		found = false
		for property in (TokenShopItem as GDScript).get_script_property_list():
			if property.name == "TokenShopItem.gd":
				found = true
				continue
			if not property.usage & PROPERTY_USAGE_EDITOR:
				continue
			if not found:
				continue
			property.name = "level_%d/%s" % [i, property.name]
			properties.append(property)
	
	return properties


func _get(property: StringName) -> Variant:
	if property.get_base_dir() == "Base":
		return base.get(property.trim_prefix("Base/"))
	
	if property.match("level_*/*"):
		var idx := property.to_int()
		var level := levels[idx]
		if level == null:
			return base.get(property.get_file())
		return level.get(property.get_file())
	
	if property == "level_count":
		return levels.size()
	
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property.get_base_dir() == "Base":
		var old_value = base.get(property.get_file())
		for level in levels:
			if level and level.get(property.get_file()) == old_value:
				level.set(property.get_file(), value)
		base.set(property.get_file(), value)
		return true
	
	if property.match("level_*/*"):
		var idx := property.to_int()
		var level := levels[idx]
		if level == null:
			level = base.duplicate()
			levels[idx] = level
		level.set(property.get_file(), value)
		return true
	
	if property == "level_count":
		levels.resize(value)
		notify_property_list_changed()
		return true
	
	return false


func _property_can_revert(property: StringName) -> bool:
	if property.match("level_*/*"):
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.match("level_*/*"):
		return base.get(property.get_file())
	return null
