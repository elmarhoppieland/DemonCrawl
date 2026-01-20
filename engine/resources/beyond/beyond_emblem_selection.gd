extends MarginContainer
class_name BeyondEmblemSelection

# ==============================================================================
const EMBLEM_COUNT_TEXT := "beyond.current-emblems"
# ==============================================================================
var _emblem_frames: Dictionary[EmblemData, BeyondEmblemDisplay] = {}
# ==============================================================================
@onready var _emblem_count_label: Label = %EmblemCountLabel
@onready var _emblems_container: HFlowContainer = %EmblemsContainer
# ==============================================================================
signal emblem_selected(emblem: EmblemData)
# ==============================================================================

func _ready() -> void:
	_emblem_count_label.text = tr(EMBLEM_COUNT_TEXT).format({ "emblems": Codex.get_total_emblem_count() })
	
	for emblem in DemonCrawl.get_full_registry().emblems:
		var emblem_count := Codex.get_emblems(emblem)
		if emblem_count == 0:
			continue
		
		var display: BeyondEmblemDisplay = load("res://engine/resources/beyond/beyond_emblem_display.tscn").instantiate()
		display.emblem = emblem
		display.count = emblem_count
		
		display.interacted.connect(func() -> void:
			display.count -= 1
			
			emblem_selected.emit(emblem)
		)
		
		_emblem_frames[emblem] = display
		
		_emblems_container.add_child(display)


## Returns an [Emblem] after it has been erased from the quest.
func return_emblem(emblem: EmblemData) -> void:
	_emblem_frames[emblem].count += 1
