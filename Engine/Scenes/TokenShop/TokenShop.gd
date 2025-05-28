@tool
extends Control
class_name TokenShop

# ==============================================================================
const CATEGORIES := preload("res://Assets/TokenShop/Categories.tres")
# ==============================================================================
static var purchased_items: Dictionary = Eternal.create({})
# ==============================================================================
var selected_category: TokenShopCategoryDisplay = null
# ==============================================================================
@onready var _category_tab_buttons: HBoxContainer = %CategoryTabButtons
@onready var _categories_container: MarginContainer = %Categories
# ==============================================================================

func _ready() -> void:
	var icon_scene := load("res://Engine/Scenes/TokenShop/TokenShopCategoryIcon.tscn") as PackedScene
	var category_scene := load("res://Engine/Scenes/TokenShop/TokenShopCategoryDisplay.tscn") as PackedScene
	
	for category in CATEGORIES.categories:
		var icon := icon_scene.instantiate() as TokenShopCategoryIcon
		icon.category = category
		_category_tab_buttons.add_child(icon)
		
		var category_display := category_scene.instantiate() as TokenShopCategoryDisplay
		category_display.category = category
		_categories_container.add_child(category_display)
		
		icon.interacted.connect(func() -> void:
			if category_display.visible:
				return
			
			selected_category.hide()
			selected_category = category_display
			category_display.show()
		)
		
		category_display.item_purchased.connect(func(item: TokenShopItemBase) -> void:
			if Codex.tokens >= item.get_cost():
				Codex.tokens -= item.get_cost()
				TokenShop.purchase(item)
				Eternity.save()
		)
	
	#const DIR := "res://Assets/TokenShop/"
	#
	#var main := true
	#for file_name in DirAccess.get_files_at(DIR):
		#var path := DIR.path_join(file_name)
		#var category := Category.load_from_file(path)
		#if not category:
			#continue
		#category.hide()
		#_categories_container.add_child(category)
		#
		#var json = ResourceLoader.load(path).data
		#
		#var texture_rect := TextureRect.new()
		#texture_rect.texture = IconManager.get_icon_data(json.icon).create_texture()
		#
		#var focus_grabber := FocusGrabber.new(main)
		#focus_grabber.interacted.connect(func():
			#if category.visible:
				#return
			#
			#for other_category: Category in _categories_container.get_children():
				#other_category.visible = other_category == category
		#)
		#texture_rect.add_child(focus_grabber)
		#
		#var tooltip_grabber := TooltipGrabber.new()
		#tooltip_grabber.text = json.name
		#texture_rect.add_child(tooltip_grabber)
		#
		#_category_tab_buttons.add_child(texture_rect)
		#
		#main = false


static func purchase(item: TokenShopItemBase) -> void:
	purchased_items[item] = purchased_items.get(item, 0) + 1


static func is_item_purchased(item: TokenShopItemBase) -> bool:
	return get_purchased_level(item) > 0


static func get_purchased_level(item: TokenShopItemBase) -> int:
	return purchased_items.get(item, 0)


#class Category extends VFlowContainer:
	#func _init() -> void:
		#add_theme_constant_override("h_separation", 2)
		#add_theme_constant_override("v_separation", 2)
	#
	#func add_item(data: TokenShopItemData) -> TokenShopItem:
		#for condition in data.conditions:
			#if condition.begins_with("!") == PlayerFlags.has_flag(condition):
				#return null
		#
		#var item := TokenShopItem.create()
		#
		#if data.flags & TokenShopItemData.Flags.DESCRIPTION_ADD_LEVEL:
			#item.item_name = tr(data.item_name) + " " + RomanNumeral.convert_to_roman(data.level + 1)
		#else:
			#item.item_name = tr(data.item_name)
		#
		#item.icon = data.icon
		#item.cost = data.cost
		#item.description = data.description
		#if data.flags & TokenShopItemData.Flags.DESCRIPTION_ADD_LEVEL:
			#item.description += " " + RomanNumeral.convert_to_roman(data.level + 1)
		#item.description_subtext = data.description_subtext
		#
		#for condition in data.unlock_conditions:
			#if condition.begins_with("!") == PlayerFlags.has_flag(condition):
				#item.lock()
				#break
		#
		#if TokenShop.get_purchased_level(data.item_name) > data.level:
			#item.purchase()
		#
		#item.purchased.connect(func():
			#TokenShop.purchase(data.item_name)
		#)
		#
		#add_child(item)
		#return item
	#
	#func insert_item(data: TokenShopItemData, after_item_name: String) -> TokenShopItem:
		#var item := add_item(data)
		#if not item:
			#return null
		#remove_child(item)
		#for i in get_child_count():
			#var child: TokenShopItem = get_child(i)
			#if child == item:
				#return item
			#if child.item_name == after_item_name:
				#child.add_sibling(item)
				#return item
		#return item
	#
	#func load_items(items_data: Array[TokenShopItemData]) -> Array[TokenShopItem]:
		#for child in get_children():
			#child.queue_free()
		#
		#var items: Array[TokenShopItem] = []
		#
		#for data in items_data:
			#var item := add_item(data)
			#if item:
				#items.append(item)
		#
		#return items
	#
	#static func load_from_file(file_path: String) -> Category:
		#var json = ResourceLoader.load(file_path).data
		#if _check_json_errors(json, file_path):
			#return null
		#
		#var category := Category.new()
		#
		#for item_data: Dictionary in json.items:
			#if _check_item_data_errors(item_data, file_path, json):
				#continue
			#
			#var data := TokenShopItemData.new()
			#
			#var flags: PackedStringArray = item_data.get("flags", [])
			#
			#var level := TokenShop.get_purchased_level(item_data.name)
			#
			#data.item_name = item_data.name
			#
			#if item_data.icon is String:
				#data.icon = IconManager.get_icon_data(item_data.icon).create_texture()
			#elif item_data.icon is Array:
				#data.icon = IconManager.get_icon_data(item_data.icon[level]).create_texture()
			#
			#if item_data.cost is float:
				#data.cost = item_data.cost
			#elif item_data.cost is Array:
				#data.cost = item_data.cost[level]
			#
			#if item_data.description is String:
				#data.description = TranslationServer.tr(item_data.description)
			#elif item_data.description is Array:
				#data.description = TranslationServer.tr(item_data.description[level])
			#
			#if "description_subtext" in item_data:
				#if "description_subtext_bullets" in flags and item_data.description_subtext is Array:
					#var bullets: PackedStringArray = item_data.description_subtext[level].map(func(a):
						#return "\n• " + TranslationServer.tr(a)
					#)
					#data.description_subtext = "".join(bullets).strip_edges()
				#else:
					#if item_data.description_subtext is String:
						#data.description_subtext = TranslationServer.tr(item_data.description_subtext)
					#elif item_data.description_subtext is Array:
						#data.description_subtext = TranslationServer.tr(item_data.description_subtext[level])
			#
			#if "description_values" in item_data:
				#data.description %= item_data.description_values[level]
			#
			#data.set_flags(item_data.get("flags", []))
			#data.conditions = item_data.get("conditions", [])
			#data.unlock_conditions = []
			#for condition in item_data.get("unlock_conditions", []):
				#match typeof(condition):
					#TYPE_STRING:
						#data.unlock_conditions.append(condition)
					#TYPE_ARRAY:
						#data.unlock_conditions.append(condition[level])
			#
			#data.level = level
			#
			#category.add_item(data)
		#
		#return category
	#
	#static func _check_json_errors(json: Variant, file_path: String) -> bool:
		#if not json is Dictionary:
			#Debug.log_error("Could not parse TokenShopCategory file at path '%s' as a JSON Dictionary." % file_path)
			#return true
		#
		#var error := false
		#
		#if not "items" in json:
			#Debug.log_error("The TokenShopCategory file at path '%s' has no key 'items'." % file_path)
			#error = true
		#elif not json.items is Array:
			#Debug.log_error("The TokenShopCategory file at path '%s' has invalid key 'items': Expected 'Array', but recieved '%s'." % [file_path, type_string(typeof(json.items))])
			#error = true
		#
		#if not "icon" in json:
			#Debug.log_error("The TokenShopCategory file at path '%s' has no key 'icon'." % file_path)
			#error = true
		#elif not json.icon is String:
			#Debug.log_error("The TokenShopCategory file at path '%s' has invalid key 'icon': Expected 'String', but recieved '%s'." % [file_path, type_string(typeof(json.icon))])
			#error = true
		#
		#return error
	#
	#static func _check_item_data_errors(item_data: Variant, file_path: String, json: Variant) -> bool:
		#if not item_data is Dictionary:
			#Debug.log_error("The TokenShopCategory file at path '%s' has an invalid item at index %s: Expected 'Dictionary', but recieved '%s'." % [file_path, json.items.find(item_data), type_string(typeof(item_data))])
			#return true
		#
		#var error := false
		#
		#const KEY_TYPES := {
			#"name": TYPE_STRING,
			#"icon": [TYPE_STRING, TYPE_ARRAY],
			#"cost": [TYPE_INT, TYPE_FLOAT, TYPE_ARRAY],
			#"description": [TYPE_STRING, TYPE_ARRAY],
			#"?description_subtext": [TYPE_STRING, TYPE_ARRAY],
			#"?description_values": TYPE_ARRAY,
			#"?conditions": TYPE_ARRAY,
			#"?unlock_conditions": TYPE_ARRAY,
			#"?flags": TYPE_ARRAY
		#}
		#for full_key: String in KEY_TYPES:
			#var optional := full_key.begins_with("?")
			#var key := full_key.trim_prefix("?")
			#if not key in item_data:
				#if optional:
					#continue
				#Debug.log_error("The TokenShopCategory file at path '%s' has an invalid item at index %s: Missing key '%s'." % [file_path, json.items.find(item_data), key])
				#error = true
			#elif KEY_TYPES[full_key] is Variant.Type:
				#if not typeof(item_data[key]) == KEY_TYPES[full_key]:
					#Debug.log_error("The TokenShopCategory file at path '%s' has an invalid item at index %s: Key '%s' should have '%s' as value type, but '%s' was given." % [file_path, json.items.find(item_data), key, type_string(KEY_TYPES[full_key]), type_string(typeof(item_data[key]))] + ("" if error or not optional else " Ignoring the key and continuing..."))
					#if optional:
						#item_data.erase(key)
					#else:
						#error = true
			#elif KEY_TYPES[full_key] is Array:
				#if not typeof(item_data[key]) in KEY_TYPES[full_key]:
					#Debug.log_error("The TokenShopCategory file at path '%s' has an invalid item at index %s: Key '%s' should have one of %s as value, but '%s' was given." % [file_path, json.items.find(item_data), key, KEY_TYPES[full_key].map(func(a: Variant.Type): return type_string(a)), type_string(typeof(item_data[key]))] + ("" if error or not optional else " Ignoring the key and continuing..."))
					#if optional:
						#item_data.erase(key)
					#else:
						#error = true
		#
		#return error
#
#
#class TokenShopItemData:
	#enum Flags {
		#INFINITE = 1,
		#DESCRIPTION_ADD_LEVEL = 2,
		#DESCRIPTION_SUBTEXT_BULLETS = 4
	#}
	#
	#var item_name := ""
	#var icon: Texture2D
	#var cost := 0
	#var description := ""
	#var description_subtext := ""
	#var flags := 0
	#var conditions: PackedStringArray
	#var unlock_conditions: PackedStringArray
	#
	#var level := 0
	#
	#func set_flags(flags_arr: PackedStringArray) -> void:
		#for flag in flags_arr:
			#flags |= Flags[flag.to_snake_case().to_upper()]
