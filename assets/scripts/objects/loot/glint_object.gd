@tool
extends Loot
class_name GlintObject

# ==============================================================================
const TITLE_COLOR := Color("ffe47a")
const MAX_LINE_LENGTH := 44
# ==============================================================================
@export var glint: GlintData :
	set(value):
		glint = value
		
		clear_texture_cache()
		emit_changed()
# ==============================================================================

func _spawn() -> void:
	var glint_list: Array[GlintData] = []
	glint_list.assign(DemonCrawl.get_full_registry().glints)
	
	if glint_list.is_empty():
		Debug.log_error("No valid glints found. Clearing the glint object...")
		clear()
		return
	
	glint = glint_list.pick_random()


func _get_name_id() -> String:
	return "object.glint"


func _get_texture() -> Texture2D:
	return glint.icon if glint else load("res://assets/beyond/glints/treasure_glint.png")


func _get_material() -> Material:
	return load("res://assets/scripts/objects/loot/loot_special.tres")


func _collect() -> bool:
	Codex.gain_glint(glint)
	
	tween_texture_to(GuiLayer.get_statbar().position + Vector2(0.0, 16.0))
	
	Toasts.add_toast(str(Codex.get_glints(glint)), get_texture())
	
	return true


func _get_annotation_title() -> String:
	return tr(glint.name)


func _get_annotation_title_color() -> Color:
	return TITLE_COLOR


func _get_annotation_subtext() -> String:
	return glint.get_description()


func _get_annotation_max_line_length() -> int:
	return MAX_LINE_LENGTH
