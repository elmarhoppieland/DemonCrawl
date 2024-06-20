extends CanvasLayer
class_name MasteryUnlockPopup

# ==============================================================================
static var _instance: MasteryUnlockPopup

static var _request_blocker := RequestBlocker.new()
# ==============================================================================
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var mastery_icon: TextureRect = %MasteryIcon
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================

static func show_unlock(mastery: String, level: int) -> void:
	await _request_blocker.wait()
	
	_request_blocker.block()
	
	mastery = "MASTERY_" + mastery.to_snake_case().to_upper()
	_instance.mastery_icon.texture.name = "mastery%d/%s" % [level, mastery]
	_instance.tooltip_grabber.text = "MASTERY_" + mastery + " " + RomanNumeral.convert_to_roman(level)
	
	var description_bullets := PackedStringArray()
	for i in level:
		description_bullets.append(_instance.tr(mastery + "_DESCRIPTION_" + str(i + 1)))
	
	_instance.tooltip_grabber.subtext = "• " + "\n• ".join(description_bullets)
	
	_instance.animation_player.play("popup_show")
	
	await _instance.animation_player.animation_finished
	
	while not Input.is_action_just_pressed("interact"):
		await _instance.get_tree().process_frame
	
	_instance.animation_player.play("popup_hide")
	
	await _instance.animation_player.animation_finished
	
	_request_blocker.lower()
