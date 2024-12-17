extends RefCounted
class_name Mastery

# ==============================================================================
static var selected_path: String = Eternal.create("") :
	set(value):
		selected_path = value
		if value.is_empty():
			return
		selected = ResourceLoader.load(value).new()
static var selected: Mastery
# ==============================================================================
var icon: Texture2D :
	get:
		if not icon:
			var identifier: String = get_script().resource_path.get_file().get_basename().to_snake_case()
			var icon_name := "mastery" + str(level) + "/" + identifier
			if not IconManager.icon_exists(icon_name):
				icon_name = "mastery/" + identifier
			icon = IconManager.get_icon_data(icon_name).create_texture()
		return icon
var level := 0 :
	set(value):
		level = value
		icon = null
# ==============================================================================

func _init() -> void:
	level = TokenShop.get_purchased_level(Mastery.get_mastery_name_from_script(get_script()))


func get_description() -> PackedStringArray:
	var description := PackedStringArray()
	
	var i := 1
	while true:
		if level < i:
			return description
		
		description.append(TranslationServer.tr("%s_DESCRIPTION_%d" % [Mastery.get_mastery_name_from_script(get_script()), i]))
		
		i += 1
	
	return description


func reload_icon() -> void:
	icon = null


static func get_mastery_name_from_script(script: Script) -> String:
	return "MASTERY_" + script.resource_path.get_file().get_basename().to_snake_case().to_upper()


static func get_unlock_text_from_script(script: Script) -> String:
	return get_mastery_name_from_script(script) + "_UNLOCK"

#region utilities

func get_quest() -> Quest:
	return Quest.get_current()


func get_quest_instance() -> QuestInstance:
	return get_quest().get_instance()


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_quest_instance().get_item_count():
		items.append(get_quest_instance().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_quest_instance().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_quest_instance().life_lose(life, source)

#endregion
