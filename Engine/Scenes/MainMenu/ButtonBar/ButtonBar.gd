extends MarginContainer

# ==============================================================================
var label_tween: Tween
var exit_tween: Tween
# ==============================================================================
@onready var buttons_container: HBoxContainer = %ButtonsContainer
@onready var padding: Control = %Padding
@onready var label: Label = %Label
# ==============================================================================

func _ready() -> void:
	for button: MainMenuButton in buttons_container.get_children():
		button.mouse_entered.connect(func() -> void:
			label.text = button.text
			label.label_settings.outline_color = button.color
			await get_tree().process_frame
			
			if label_tween:
				label_tween.kill()
			if exit_tween:
				exit_tween.kill()
			
			var final_val := button.position.x + buttons_container.position.x + (button.size.x - label.size.x) / 2
			if label.modulate.a > 0:
				label_tween = create_tween()
				label_tween.tween_property(padding, "custom_minimum_size:x", final_val, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				label_tween.parallel().tween_property(label, "modulate:a", 1.0, 0.4)
			else:
				padding.custom_minimum_size.x = final_val
				label.modulate.a = 1
		)
		button.mouse_exited.connect(func() -> void:
			exit_tween = create_tween()
			exit_tween.tween_property(label, "modulate:a", 0.0, 0.4)
		)
