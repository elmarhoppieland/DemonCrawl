extends MarginContainer
class_name BeyondQuestSelection

# ==============================================================================
const FEE_TEXT := "difficulty.beyond.fee"
const CURRENT_TOKENS_TEXT := "difficulty.beyond.current-tokens"
# ==============================================================================
var _artifacts: Array[StageFile] = [null, null, null]
# ==============================================================================
@onready var _artifact_texture_rects: Array[TextureRect] = [
	%ArtifactTextureRect1,
	%ArtifactTextureRect2,
	%ArtifactTextureRect3
]
@onready var _slots: Array[Frame] = [
	%ArtifactFrame1,
	%ArtifactFrame2,
	%ArtifactFrame3,
	%EmblemFrame,
	%GlintFrame
]
@onready var _fee_label: Label = %FeeLabel
@onready var _current_tokens_label: Label = %CurrentTokensLabel
# ==============================================================================
## Emitted when an artifact slot is right-clicked, after the slot has been cleared.
signal artifact_erased(stage: StageFile)
# ==============================================================================

func _ready() -> void:
	_fee_label.text = tr(FEE_TEXT).format({ "token_fee": 1 })
	_current_tokens_label.text = tr(CURRENT_TOKENS_TEXT).format({ "tokens": Codex.tokens })


## Inserts an [Artifact] at the currently selected slot. If no [Artifact] slot is
## currently selected, this method fails.
func insert_artifact(stage: StageFile) -> void:
	var index := QuestsManager.selected_quest_index
	if index >= _artifacts.size():
		Debug.log_error("Cannot add artifact out of bounds at index %s." % index)
		return
	
	if _artifacts[index]:
		erase_artifact(index)
	
	var selected := _artifact_texture_rects[index]
	selected.texture = stage.artifact_texture
	
	var tooltip_grabber := selected.get_child(0) as TooltipGrabber
	tooltip_grabber.text = tr(stage.artifact_name).to_upper()
	tooltip_grabber.text_color = Artifact.TITLE_COLOR
	tooltip_grabber.subtext = tr("object.artifact.description").format({ "stage": tr(stage.name) })
	
	_artifacts[index] = stage
	
	select_slot(index + 1)


## Erases the artifact at the given [param index].
func erase_artifact(index: int) -> void:
	if index >= _artifacts.size():
		Debug.log_error("Cannot erase artifact out of bounds at index %s." % index)
		return
	
	var texture_rect := _artifact_texture_rects[index]
	texture_rect.texture = null
	
	var tooltip_grabber := texture_rect.get_child(0) as TooltipGrabber
	tooltip_grabber.text = ""
	tooltip_grabber.subtext = ""

	var stage := _artifacts[index]
	if stage == null:
		return
	
	_artifacts[index] = null
	
	artifact_erased.emit(stage)


## Returns whether an [Artifact] slot is currently selected.
func is_artifact_slot_selected() -> bool:
	return QuestsManager.selected_quest_index < _artifacts.size()


## Selects the slot at the given [param index].
func select_slot(index: int) -> void:
	index = clampi(index, 0, _slots.size() - 1)
	
	QuestsManager.selected_quest_index = index
	
	get_tree().process_frame.connect(_slots[index].interact, CONNECT_ONE_SHOT)


## Returns the list of currently specified [Artifact]s. This always returns an [Array]
## of size [code]3[/code]. If one or more slots is empty, this method will return
## [code]null[/code] for those slots.
func get_artifacts() -> Array[StageFile]:
	return _artifacts


## Returns [code]true[/code] if the selected quest can be generated, i.e. all
## artifact slots have been filled with valid artifacts.
func can_generate_quest() -> bool:
	return null not in _artifacts


func _on_slot_interacted(slot_idx: int) -> void:
	QuestsManager.selected_quest_index = slot_idx


func _on_slot_second_interacted(slot_idx: int) -> void:
	if slot_idx < _artifacts.size():
		erase_artifact(slot_idx)
	else:
		Debug.log_error("Erasing a non-Artifact slot is not yet implemented.")
