extends Control
class_name StageClearReward

# ==============================================================================
@export var reward_name := "" :
	set(value):
		reward_name = value
		if not is_node_ready():
			await ready
		
		icon.texture.name = "stage_reward_" + value
@export var amount := 0
# ==============================================================================
var shown := false
# ==============================================================================
@onready var icon: TextureRect = %Icon
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func start(_amount: int) -> void:
	if not shown:
		amount = _amount
		animation_player.play("show")
		await animation_player.animation_finished


func instant() -> void:
	animation_player.play("show", -1, INF)
	animation_player.advance(INF)


static func create(_reward_name: String = "") -> StageClearReward:
	var instance: StageClearReward = preload("res://engine/scenes/stage_scene/stage_clear_reward.tscn").instantiate()
	instance.reward_name = _reward_name
	return instance


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"show":
		tooltip_grabber.text = "%s +%d%s" % [
			tr("stage.reward." + reward_name.to_snake_case().to_lower().replace("_", "-")),
			amount,
			tr("generic.xp")
		]
		tooltip_grabber.subtext = tr("stage.reward." + reward_name.to_snake_case().to_lower().replace("_", "-") + ".subtext")
		shown = true
