@tool
extends Loot
class_name EmblemObject

# ==============================================================================
const TITLE_COLOR := Color("7ae4ff")
const MAX_LINE_LENGTH := 45
# ==============================================================================
@export var emblem: EmblemData :
	set(value):
		emblem = value
		
		clear_texture_cache()
		emit_changed()
# ==============================================================================

static func _can_spawn_in_quest(quest: Quest) -> bool:
	return quest.source_file.emblem_level >= 1


func _spawn() -> void:
	var emblem_list: Array[EmblemData] = []
	emblem_list.assign(DemonCrawl.get_full_registry().emblems.filter(func(e: EmblemData) -> bool:
		if not e.normal:
			return false
		if e.level <= 1:
			return true
		return e.level <= get_quest().source_file.emblem_level
	))
	
	if emblem_list.is_empty():
		Debug.log_error("No valid normal emblems found. Clearing the emblem object...")
		clear()
		return
	
	emblem = emblem_list.pick_random()


func _get_name_id() -> String:
	return "object.emblem"


func _get_texture() -> Texture2D:
	return emblem.icon if emblem else load("res://assets/beyond/emblems/level_1/breaking_the_seal.png")


func _get_material() -> Material:
	return load("res://assets/scripts/objects/loot/loot_special.tres")


func _collect() -> bool:
	Codex.gain_emblem(emblem)
	
	tween_texture_to(GuiLayer.get_statbar().position + Vector2(0.0, 16.0))
	
	Toasts.add_toast(str(Codex.get_emblems(emblem)), get_texture())
	
	return true


func _get_annotation_title() -> String:
	return tr(emblem.name)


func _get_annotation_title_color() -> Color:
	return TITLE_COLOR


func _get_annotation_subtext() -> String:
	return emblem.get_description()


func _get_annotation_max_line_length() -> int:
	return MAX_LINE_LENGTH
