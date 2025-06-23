extends CanvasLayer
class_name DCPopup

# ==============================================================================
var _popup_visible := false : get = is_popup_visible
# ==============================================================================
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal popup_shown()
signal popup_hidden()
# ==============================================================================

func _process(_delta: float) -> void:
	if visible and _popup_visible and not _animation_player.is_playing() and Input.is_action_just_pressed("interact"):
		popup_hide()


func popup_show() -> void:
	_popup_visible = true
	_animation_player.play("popup_show")
	await _animation_player.animation_finished
	popup_shown.emit()


func popup_hide() -> void:
	_animation_player.play("popup_hide")
	await _animation_player.animation_finished
	_popup_visible = false
	popup_hidden.emit()


func is_popup_visible() -> bool:
	return _popup_visible
