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
	if _get_stage_file():
		return _get_stage_file().artifact_texture
	if Quest.has_current() and Quest.get_current().has_current_stage():
		var artifacts := Quest.get_current().get_current_stage().get_stage().file.get_artifacts()
		if not artifacts.is_empty():
			return artifacts[0].artifact_texture
	return load("res://assets/skins/forest/artifact.png")


func _can_interact() -> bool:
	return _get_stage_file() != null


func _collect() -> bool:
	var file := _get_stage_file()
	Codex.gain_artifact(file)
	
	tween_texture_to(GuiLayer.get_statbar().position + Vector2(0.0, 16.0))
	
	Toasts.add_toast(str(Codex.get_artifacts(file)), get_texture())
	
	return true


func _get_material() -> Material:
	return load("res://assets/scripts/objects/loot/loot_special.tres")


func _get_annotation_title() -> String:
	var file := _get_stage_file()
	if not file:
		return ""
	return tr(file.artifact_name).to_upper()


func _get_annotation_subtext() -> String:
	var file := _get_stage_file()
	if not file:
		return ""
	return tr("object.artifact.description").format({"stage": tr(file.name)})


func _get_annotation_title_color() -> Color:
	return TITLE_COLOR


func _get_stage_file() -> StageFile:
	if stage_file:
		return stage_file
	if not get_stage():
		return null
	
	var artifacts := get_stage().file.get_artifacts()
	if artifacts.is_empty():
		return null
	return artifacts[0]


static func _can_spawn_in_cell(cell: CellData) -> bool:
	return not cell.get_stage().file.get_artifacts().is_empty()
