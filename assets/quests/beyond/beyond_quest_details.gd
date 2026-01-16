extends MarginContainer
class_name BeyondQuestDetails

# ==============================================================================
@onready var _artifact_selection: BeyondArtifactSelection = %BeyondArtifactSelection
# ==============================================================================
signal artifact_selected(stage: StageFile)
# ==============================================================================

## Returns an [Artifact] after is has been erased from the quest.
func return_artifact(stage: StageFile) -> void:
	_artifact_selection.return_artifact(stage)


func _on_artifact_selected(stage: StageFile) -> void:
	artifact_selected.emit(stage)
