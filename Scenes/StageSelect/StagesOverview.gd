extends VBoxContainer
class_name StagesOverview

## An overview of the stages in the [Quest].

# ==============================================================================
static var selected_stage: Stage
# ==============================================================================
@onready var _icon_flow_container: HFlowContainer = %IconFlowContainer
# ==============================================================================
signal icon_selected(icon: StageIcon)
# ==============================================================================

func _ready() -> void:
	for stage in Quest.stages:
		var icon: StageIcon = ResourceLoader.load("res://Scenes/StageSelect/StageIcon.tscn").instantiate()
		icon.stage = Stage.new(stage)
		_icon_flow_container.add_child(icon)
		
		icon.selected.connect(func():
			StagesOverview.selected_stage = icon.stage
			icon_selected.emit(icon)
		)
	
	if owner:
		await owner.ready
	await get_tree().process_frame
	_icon_flow_container.get_child(0).select()
