extends MarginContainer
class_name BeyondQuestDetails

# ==============================================================================
@onready var _artifact_selection: BeyondArtifactSelection = %BeyondArtifactSelection
@onready var _emblem_selection: BeyondEmblemSelection = %BeyondEmblemSelection
@onready var _glint_selection: BeyondGlintSelection = %BeyondGlintSelection
# ==============================================================================
signal artifact_selected(stage: StageFile)
signal emblem_selected(emblem: EmblemData)
signal glint_selected(glint: GlintData)
# ==============================================================================

## Returns an [Artifact] after is has been erased from the quest.
func set_artifact_count(stage: StageFile, new_count: int) -> void:
	_artifact_selection.set_artifact_count(stage, new_count)


## Returns an [Emblem] after is has been erased from the quest.
func return_emblem(emblem: EmblemData) -> void:
	_emblem_selection.return_emblem(emblem)


## Returns a [Glint] after is has been erased from the quest.
func return_glint(glint: GlintData) -> void:
	_glint_selection.return_glint(glint)


func show_artifacts() -> void:
	_artifact_selection.show()
	_emblem_selection.hide()
	_glint_selection.hide()


func show_emblems() -> void:
	_artifact_selection.hide()
	_emblem_selection.show()
	_glint_selection.hide()


func show_glints() -> void:
	_artifact_selection.hide()
	_emblem_selection.hide()
	_glint_selection.show()


func _on_artifact_selected(stage: StageFile) -> void:
	artifact_selected.emit(stage)


func _on_emblem_selected(emblem: EmblemData) -> void:
	emblem_selected.emit(emblem)


func _on_glint_selected(glint: GlintData) -> void:
	glint_selected.emit(glint)
