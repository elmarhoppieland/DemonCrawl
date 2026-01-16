@tool
extends Loot
class_name Artifact

# ==============================================================================
const TITLE_COLOR := Color("c54bfd")
# ==============================================================================
@export var stage_file: StageFile
# ==============================================================================

func _get_name_id() -> String:
	return "object.artifact"


func _get_texture() -> Texture2D:
	if stage_file:
		return stage_file.artifact_texture
	if Quest.has_current() and Quest.get_current().has_current_stage():
		return Quest.get_current().get_current_stage().get_stage().file.artifact_texture
	return load("res://assets/skins/forest/artifact.png")


func _can_interact() -> bool:
	return stage_file != null or get_stage()


func _collect() -> bool:
	var file := stage_file if stage_file else get_stage().file # we require one of these to exist 
	if file in Codex.artifacts:
		Codex.artifacts[file] += 1
	else:
		Codex.artifacts[file] = 1
	
	tween_texture_to(GuiLayer.get_statbar().position + Vector2(0.0, 16.0))
	
	Toasts.add_toast(str(Codex.artifacts[file]), get_texture())
	
	return true


func _get_material() -> Material:
	return load("res://assets/scripts/objects/loot/loot_special.tres")


func _get_annotation_title() -> String:
	var file := stage_file if stage_file else get_stage().file if get_stage() else null
	if not file:
		return ""
	return tr(file.artifact_name).to_upper()


func _get_annotation_subtext() -> String:
	var file := stage_file if stage_file else get_stage().file if get_stage() else null
	if not file:
		return ""
	return tr("object.artifact.description").format({"stage": tr(file.name)})


func _get_annotation_title_color() -> Color:
	return TITLE_COLOR


static func _can_spawn(cell: CellData) -> bool:
	return cell.get_stage().file.artifact_texture != null
