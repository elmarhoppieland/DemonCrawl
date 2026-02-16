@tool
extends StageTemplateDefaultBase
class_name RandomStageTemplate

# ==============================================================================

func _generate() -> Stage:
	var stage_pool: Array[StageFile] = []
	stage_pool.assign(DemonCrawl.get_full_registry().stages.filter(func(stage: StageFile) -> bool:
		return stage.normal
	))
	
	var file := CombinedStageFile.new(stage_pool.pick_random(), stage_pool.pick_random())
	return Stage.new(file)
