extends MarginContainer
class_name BeyondQuestSelection

# ==============================================================================
const FEE_TEXT := "beyond.fee"
const CURRENT_TOKENS_TEXT := "beyond.current-tokens"
# ==============================================================================
var _artifacts: Array[StageFile] = [null, null, null]
var _emblem: EmblemData
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
@onready var _artifact_count_labels: Array[Label] = [
	%ArtifactCountLabel1,
	%ArtifactCountLabel2,
	%ArtifactCountLabel3
]
@onready var _emblem_texture_rect: TextureRect = %EmblemTextureRect
@onready var _fee_label: Label = %FeeLabel
@onready var _current_tokens_label: Label = %CurrentTokensLabel
# ==============================================================================
## Emitted when an artifact slot is selected.
signal artifact_slot_selected(slot_idx: int)
## Emitted when the emblem slot is selected.
signal emblem_slot_selected()

## Emitted when an artifact slot is right-clicked, after the slot has been cleared.
signal artifact_erased(stage: StageFile)
## Emitted when the emblem slot is right-clicked, after the slot has been cleared.
signal emblem_erased(emblem: EmblemData)
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
	
	if _artifacts[index] == stage:
		select_slot(index + 1)
		return
	
	var new_used_artifacts := 1
	for artifact in _artifacts:
		if artifact == stage:
			new_used_artifacts += 1
	
	var artifact_cost := _emblem.artifact_cost if _emblem else 1
	if new_used_artifacts * artifact_cost > Codex.get_artifacts(stage):
		Toasts.add_toast(tr("beyond.artifact-too-expensive").format({
			"artifact_cost": artifact_cost,
			"artifact_name": tr(stage.artifact_name_plural)
		}), stage.artifact_texture)
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
	
	_update_artifact_count(index)
	
	select_slot(index + 1)


## Inserts an [Emblem] at the emblem slot.
func insert_emblem(emblem: EmblemData) -> void:
	if _emblem:
		erase_emblem()
	
	_emblem = emblem
	_emblem_texture_rect.texture = emblem.icon
	
	var tooltip_grabber := _emblem_texture_rect.get_child(0) as TooltipGrabber
	tooltip_grabber.text = tr(emblem.name).to_upper()
	tooltip_grabber.text_color = EmblemObject.TITLE_COLOR
	tooltip_grabber.subtext = emblem.get_description()
	
	_fee_label.text = tr(FEE_TEXT).format({ "token_fee": emblem.token_cost })
	
	for i in _artifacts.size():
		_update_artifact_count(i)
	
	select_slot(QuestsManager.selected_quest_index + 1)


## Erases the artifact at the given [param index].
func erase_artifact(index: int) -> void:
	if index >= _artifacts.size():
		Debug.log_error("Cannot erase artifact out of bounds at index %s." % index)
		return
	
	var texture_rect := _artifact_texture_rects[index]
	texture_rect.texture = null
	
	var tooltip_grabber := texture_rect.get_child(0) as TooltipGrabber
	tooltip_grabber.text = "beyond.artifact-slot-tooltip"
	tooltip_grabber.subtext = ""
	tooltip_grabber.text_color = Color.WHITE
	
	var stage := _artifacts[index]
	if stage == null:
		return
	
	_artifacts[index] = null
	
	_update_artifact_count(index)
	
	artifact_erased.emit(stage)


## Erases the currently inserted [Emblem].
func erase_emblem() -> void:
	_emblem_texture_rect.texture = null
	
	var tooltip_grabber := _emblem_texture_rect.get_child(0) as TooltipGrabber
	tooltip_grabber.text = "beyond.emblem-slot-tooltip"
	tooltip_grabber.subtext = ""
	tooltip_grabber.text_color = Color.WHITE
	
	_fee_label.text = tr(FEE_TEXT).format({ "token_fee": 1 })
	
	var emblem := _emblem
	if emblem == null:
		return
	
	_emblem = null
	
	for i in _artifacts.size():
		_update_artifact_count(i)
	
	emblem_erased.emit(emblem)


func _update_artifact_count(slot_idx: int) -> void:
	var count_label := _artifact_count_labels[slot_idx]
	
	if _artifacts[slot_idx] == null:
		count_label.text = ""
		return
	
	if not _emblem:
		count_label.text = ""
		return
	
	var artifact_count := 0
	for i in _artifacts.size():
		if i > slot_idx:
			break
		if _artifacts[i] == _artifacts[slot_idx]:
			artifact_count += 1
	
	if artifact_count * _emblem.artifact_cost > Codex.get_artifacts(_artifacts[slot_idx]):
		erase_artifact(slot_idx)
		return
	
	if _emblem.artifact_cost < 1000:
		count_label.text = str(_emblem.artifact_cost)
	else:
		count_label.text = str(_emblem.artifact_cost / 1000) + "K"


## Returns whether an [Artifact] slot is currently selected.
func is_artifact_slot(slot_idx: int) -> bool:
	return slot_idx < _artifacts.size()


## Returns whether the [Emblem] slot is currently selected.
func is_emblem_slot(slot_idx: int) -> bool:
	if slot_idx >= _slots.size():
		return false
	return _slots[slot_idx].is_ancestor_of(_emblem_texture_rect)


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


## Returns the currently selected [Emblem].
func get_emblem() -> EmblemData:
	return _emblem


## Returns [code]true[/code] if the selected quest can be generated, i.e. all
## artifact slots have been filled with valid artifacts.
func can_generate_quest() -> bool:
	return null not in _artifacts


func _on_slot_interacted(slot_idx: int) -> void:
	QuestsManager.selected_quest_index = slot_idx
	
	if is_artifact_slot(slot_idx):
		artifact_slot_selected.emit(slot_idx)
	elif is_emblem_slot(slot_idx):
		emblem_slot_selected.emit()


func _on_slot_second_interacted(slot_idx: int) -> void:
	if is_artifact_slot(slot_idx):
		erase_artifact(slot_idx)
	elif is_emblem_slot(slot_idx):
		erase_emblem()
	else:
		Debug.log_error("Erasing a non-Artifact slot is not yet implemented.")
