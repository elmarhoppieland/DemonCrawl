extends MarginContainer

# ==============================================================================
var equipment_button_hovered := false
# ==============================================================================
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal edit_equipment()
# ==============================================================================

func _process(_delta: float) -> void:
	if equipment_button_hovered and Input.is_action_just_pressed("interact"):
		edit_equipment.emit()


func _on_equipment_button_mouse_entered() -> void:
	equipment_button_hovered = true
	animation_player.play("equipment_button_show")


func _on_equipment_button_mouse_exited() -> void:
	equipment_button_hovered = false
	animation_player.play_backwards("equipment_button_show")
