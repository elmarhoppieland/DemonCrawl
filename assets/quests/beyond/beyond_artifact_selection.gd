extends MarginContainer
class_name BeyondArtifactSelection

# ==============================================================================
const ARTIFACT_COUNT_TEXT := "difficulty.beyond.current-artifacts"
# ==============================================================================
var _artifact_frames: Dictionary[StageFile, BeyondArtifactDisplay] = {}
# ==============================================================================
@onready var _artifact_count_label: Label = %ArtifactCountLabel
@onready var _artifacts_container: HFlowContainer = %ArtifactsContainer
# ==============================================================================
signal artifact_selected(stage: StageFile)
# ==============================================================================

func _ready() -> void:
	_artifact_count_label.text = tr(ARTIFACT_COUNT_TEXT).format({ "artifacts": Codex.get_total_artifact_count() })
	
	for stage in DemonCrawl.get_full_registry().stages:
		if stage not in Codex.artifacts:
			continue
		
		var artifact_count := Codex.artifacts[stage]
		if not artifact_count:
			continue
		
		var display: BeyondArtifactDisplay = load("res://assets/quests/beyond/beyond_artifact_display.tscn").instantiate()
		display.stage = stage
		display.count = artifact_count
		
		display.interacted.connect(func() -> void:
			display.count -= 1
			
			artifact_selected.emit(stage)
		)
		
		_artifact_frames[stage] = display
		
		_artifacts_container.add_child(display)


## Returns an [Artifact] after it has been erased from the quest.
func return_artifact(stage: StageFile) -> void:
	_artifact_frames[stage].count += 1
