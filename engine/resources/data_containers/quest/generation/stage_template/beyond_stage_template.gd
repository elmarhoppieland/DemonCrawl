extends StageTemplateDefaultBase
class_name BeyondStageTemplate

# ==============================================================================
## The first index to use for the stage's theme. The stage's primary and secondary
## themes will be randomly selected from [member index_a] or [member index_b].
@export var index_a := 0
## The second to use for the stage's theme. The stage's primary and secondary
## themes will be randomly selected from [member index_a] or [member index_b].
@export var index_b := -1
# ==============================================================================
var stage: StageFileBase
# ==============================================================================

## Sets the stage file from the given [param stage_list]. This method [b]must[/b]
## be called before generating.
func set_stage_from_list(stage_list: Array[StageFile]) -> void:
	if index_b < 0 or stage_list[index_a] == stage_list[index_b]:
		stage = stage_list[index_a]
		return
	
	var primary: StageFile
	var secondary: StageFile
	
	if randi() % 2:
		primary = stage_list[index_a]
		secondary = stage_list[index_b]
	else:
		primary = stage_list[index_b]
		secondary = stage_list[index_a]
	
	stage = CombinedStageFile.new(primary, secondary)


func _generate() -> Stage:
	assert(stage != null, "The stage has not been obtained from the list. set_stage_from_list() must be called before generating.")
	return Stage.new(stage)
