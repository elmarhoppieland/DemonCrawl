extends MarginContainer
class_name BeyondArtifactSelection

# ==============================================================================
const ARTIFACT_COUNT_TEXT := "beyond.current-artifacts"
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
		
		var display: BeyondArtifactDisplay = load("res://engine/resources/beyond/beyond_artifact_display.tscn").instantiate()
		display.stage = stage
		display.count = artifact_count
		
		display.interacted.connect(func() -> void:
			artifact_selected.emit(stage)
		)
		
		_artifact_frames[stage] = display
		
		_artifacts_container.add_child(display)


## Sets the artifact count of [param stage] to [param new_count].
func set_artifact_count(stage: StageFile, new_count: int) -> void:
	_artifact_frames[stage].count = new_count
