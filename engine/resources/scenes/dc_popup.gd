extends CanvasLayer
class_name DCPopup

# ==============================================================================
static var _instance: DCPopup

var _popup_visible := false
# ==============================================================================
@onready var _contents_container: MarginContainer = %ContentsContainer
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal _popup_shown()
signal _popup_hidden()
# ==============================================================================

func _enter_tree() -> void:
	_popup_visible = false
	
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _process(_delta: float) -> void:
	if visible and _popup_visible and not _animation_player.is_playing() and Input.is_action_just_pressed("interact"):
		_popup_hide()


static func popup_show(popup: PackedScene) -> void:
	var instance := popup.instantiate()
	await popup_show_instance(instance)
	instance.queue_free()


static func popup_show_instance(instance: Node) -> void:
	while is_popup_visible():
		await _instance._popup_hidden
	
	_instance._contents_container.add_child(instance)
	await _instance._popup_show()
	await _instance._popup_hidden


func _popup_show() -> void:
	_popup_visible = true
	_animation_player.play("popup_show")
	await _animation_player.animation_finished
	_popup_shown.emit()


func _popup_hide() -> void:
	_animation_player.play("popup_hide")
	await _animation_player.animation_finished
	_popup_visible = false
	_popup_hidden.emit()


static func is_popup_visible() -> bool:
	return _instance._popup_visible
