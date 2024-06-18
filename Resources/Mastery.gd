extends RefCounted
class_name Mastery

# ==============================================================================
static var selected_path: String = SavesManager.get_value("selected_path", Mastery, "") :
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
			if not Icon.has_icon(icon_name):
				icon_name = "mastery/" + identifier
			icon = AssetManager.get_icon(icon_name)
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
		
		description.append(Translator.tr("%s_DESCRIPTION_%d" % [Mastery.get_mastery_name_from_script(get_script()), i]))
		
		i += 1
	
	return description


func reload_icon() -> void:
	icon = null


static func get_mastery_name_from_script(script: Script) -> String:
	return "MASTERY_" + script.resource_path.get_file().get_basename().to_snake_case().to_upper()


static func get_unlock_text_from_script(script: Script) -> String:
	return get_mastery_name_from_script(script) + "_UNLOCK"
