extends VBoxContainer
class_name FinishPopupContents

# ==============================================================================
var rewards_showing := false
var rewards_shown := false
# ==============================================================================
@onready var stage_clear_rewards_container: HBoxContainer = %StageClearRewardsContainer
@onready var xp_label: Label = %XPLabel
@onready var xp_progress_bar: TextureProgressBar = %XPProgressBar
# ==============================================================================
signal finished()
# ==============================================================================

func _ready() -> void:
	xp_label.text = "%d/%d" % [XPBar.xp, XPBar.get_next_level_xp()]
	xp_progress_bar.value = XPBar.xp
	xp_progress_bar.max_value = XPBar.get_next_level_xp()


func show_rewards() -> void:
	if rewards_showing:
		return
	
	rewards_showing = true
	
	var total_xp := 0
	var total_score := 0
	
	var types := Stage.get_current().get_instance().get_reward_types()
	stage_clear_rewards_container.custom_minimum_size.x = 20 * types.size() - 4
	for reward_type in types:
		var reward := StageClearReward.create(reward_type)
		stage_clear_rewards_container.add_child(reward)
		
		var reward_amount := get_score_reward(reward_type)
		
		total_xp += reward_amount.xp
		total_score += reward_amount.score
		
		await reward.start(reward_amount.xp)
		await get_tree().create_timer(0.2).timeout
	
	await get_tree().create_timer(0.2).timeout
	
	const XP_PER_SEC := 50.0
	var leftover_xp := 0.0
	while true:
		var xp_to_add := XP_PER_SEC * get_process_delta_time()
		
		xp_to_add += leftover_xp
		
		var whole_xp_to_add := int(xp_to_add)
		leftover_xp = xp_to_add - whole_xp_to_add
		
		total_xp -= whole_xp_to_add
		
		if total_xp < 0:
			whole_xp_to_add += total_xp
			total_xp = 0
		
		XPBar.xp += whole_xp_to_add
		
		if total_xp <= 0:
			break
		
		await get_tree().process_frame
	
	Quest.get_current().get_attributes().score += total_score
	
	rewards_showing = false
	rewards_shown = true


func _process(_delta: float) -> void:
	if is_visible_in_tree() and Input.is_action_just_pressed("interact"):
		if rewards_shown:
			finished.emit()
		else:
			for reward: StageClearReward in stage_clear_rewards_container.get_children():
				reward.instant()
	
	if is_visible_in_tree():
		xp_progress_bar.value = XPBar.xp
		xp_label.text = "%d/%d" % [XPBar.xp, XPBar.get_next_level_xp()]


func get_score_reward(type: StringName) -> ScoreReward:
	match type:
		"victory":
			return ScoreReward.new(ceili(Stage.get_current().get_instance().get_3bv() * 1.4))
		"flagless":
			return ScoreReward.new(ceili(Stage.get_current().get_instance().get_3bv() * 0.7))
		"untouchable":
			return ScoreReward.new(ceili(Stage.get_current().get_instance().get_3bv() * 0.35))
		"thrifty":
			var specials := 0
			
			for i in Quest.get_current().stages.size():
				if i == Quest.get_current().selected_stage_idx:
					break
				if Quest.get_current().stages[i] is SpecialStage:
					specials += 1
			
			return ScoreReward.new(ceili(Stage.get_current().get_instance().get_3bv() * specials * 0.35 / 6))
		"charitable":
			var reward := ScoreReward.new(0)
			for cell in Stage.get_current().get_instance().get_cells():
				if cell.object:
					reward.add(cell.object.get_charitable_amount())
			
			reward.cap(ceili(Stage.get_current().get_instance().get_3bv() * 0.7))
			return reward
		"heartless":
			var reward := ScoreReward.new(0)
			if Quest.get_current().get_stats().life < Quest.get_current().get_stats().max_life:
				for cell in Stage.get_current().get_instance().get_cells():
					if cell.object is Heart:
						reward.add(5)
			
			reward.cap(ceili(Stage.get_current().get_instance().get_3bv() * 0.7))
			return reward
		_:
			Debug.log_error("Unknown reward name '%s'." % type)
			return null


class ScoreReward:
	var xp := 0
	var score := 0
	
	func _init(_xp: int, _score: int = -1) -> void:
		xp = _xp
		
		if _score < 0:
			score = xp
		else:
			score = _score
	
	func add(_xp: int, _score: int = -1) -> void:
		xp += _xp
		if _score < 0:
			score += _xp
		else:
			score += _score
	
	func cap(maximum: int) -> void:
		xp = mini(xp, maximum)
		score = mini(xp, maximum)
