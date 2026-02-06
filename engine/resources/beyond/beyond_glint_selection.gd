extends MarginContainer
class_name BeyondGlintSelection

# ==============================================================================
const EMBLEM_COUNT_TEXT := "beyond.current-glints"
# ==============================================================================
var _glint_frames: Dictionary[GlintData, BeyondGlintDisplay] = {}
# ==============================================================================
@onready var _glint_count_label: Label = %GlintCountLabel
@onready var _glints_container: HFlowContainer = %GlintsContainer
# ==============================================================================
signal glint_selected(glint: GlintData)
# ==============================================================================

func _ready() -> void:
	_update()
	
	Codex.glints_changed.connect(_update)


func _update() -> void:
	_glint_count_label.text = tr(EMBLEM_COUNT_TEXT).format({ "glints": Codex.get_total_glint_count() })
	
	for child in _glints_container.get_children():
		child.queue_free()
	
	_glint_frames.clear()
	
	for glint in DemonCrawl.get_full_registry().glints:
		var glint_count := Codex.get_glints(glint)
		if glint_count == 0:
			continue
		
		var display: BeyondGlintDisplay = load("res://engine/resources/beyond/beyond_glint_display.tscn").instantiate()
		display.glint = glint
		display.count = glint_count
		
		display.interacted.connect(func() -> void:
			display.count -= 1
			
			glint_selected.emit(glint)
		)
		
		_glint_frames[glint] = display
		
		_glints_container.add_child(display)


## Returns an [Glint] after it has been erased from the quest.
func return_glint(glint: GlintData) -> void:
	_glint_frames[glint].count += 1
