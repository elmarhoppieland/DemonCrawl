extends MarginContainer
class_name FinishButton

# ==============================================================================
@onready var animation_player = %AnimationPlayer
# ==============================================================================
signal pressed()
# ==============================================================================

func _enter_tree() -> void:
	hide()


func show_button() -> void:
	show()
	animation_player.play("grow_button")


func _on_texture_button_pressed() -> void:
	pressed.emit()
