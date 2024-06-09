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
	var rng := RandomNumberGenerator.new()
	if Quest.stages.is_empty():
		QuestSelect.selected_quest.pack().generate(rng)
		
		Stats.max_life = QuestsOverview.selected_difficulty.get_starting_lives()
		Stats.life = Stats.max_life
		Stats.defense = 0
		Stats.coins = 0
		
		Toasts.add_debug_toast("Quest started: %s on difficulty %s" % [tr(Quest.quest_name), QuestsOverview.selected_difficulty.get_name()])
	
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
	
	#if owner:
		#await owner.ready
	#await get_tree().process_frame
	#_icon_flow_container.get_child(0).select()
