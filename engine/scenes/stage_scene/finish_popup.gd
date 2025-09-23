extends CanvasLayer
class_name FinishPopup

# ==============================================================================
@onready var _finish_popup_contents: FinishPopupContents = %FinishPopupContents
@onready var _animation_player = %AnimationPlayer
# ==============================================================================

func _ready() -> void:
	hide()


func popup() -> void:
	show()
	_animation_player.play("popup_show")
	
	await _animation_player.animation_finished
	
	_finish_popup_contents.show_rewards()
	
	await _finish_popup_contents.finished
	
	_animation_player.play("popup_hide")
	
	await _animation_player.animation_finished
	
	hide()
