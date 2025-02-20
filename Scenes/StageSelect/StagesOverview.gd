extends VBoxContainer
class_name StagesOverview

## An overview of the stages in the [Quest].

# ==============================================================================
static var selected_stage: Stage ## The currently selected [Stage].
# ==============================================================================
@onready var _icon_flow_container: HFlowContainer = %IconFlowContainer
# ==============================================================================
signal icon_selected(icon: StageIcon) ## Emitted when a stage icon has been selected.
# ==============================================================================

func _ready() -> void:
	if Mastery.selected:
		EffectManager.register_object(Mastery.selected, EffectManager.Priority.MASTERY, 0) # TODO: determine subpriority
	
	var rng := RandomNumberGenerator.new()
	if Quest.stages.is_empty():
		Quest.start_new(rng)
	
	if not selected_stage in Quest.stages:
		selected_stage = Quest.stages[0]
	
	var peek_counter := 2
	for stage in Quest.stages:
		var icon: StageIcon
		icon = ResourceLoader.load("res://Scenes/StageSelect/StageIcon.tscn").instantiate()
		icon.stage = stage
		_icon_flow_container.add_child(icon)
		
		if stage == selected_stage:
			icon.select.call_deferred()
		
		if stage.locked:
			if peek_counter > 0:
				icon.show_icon = true
				peek_counter -= 1
			else:
				icon.show_icon = false
		else:
			peek_counter = 2
			icon.show_icon = true
		
		icon.selected.connect(func():
			StagesOverview.selected_stage = stage
			icon_selected.emit(icon)
		)
		
		if not stage is SpecialStage:
			AssetManager.preload_skin_asset_pack(stage.name)
