@tool
extends HBoxContainer
class_name CoinValue

# ==============================================================================
@export var coin_value := 0 :
	set(value):
		coin_value = value
		
		if not is_node_ready():
			await ready
		
		cost_label.text = str(coin_value)
		
		update_font_color()
@export var red_if_too_expensive := true :
	set(value):
		red_if_too_expensive = value
		
		if not is_node_ready():
			await ready
		
		update_font_color()
# ==============================================================================
@onready var cost_label: Label = %CostLabel
# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	while is_inside_tree():
		update_font_color()
		
		await EffectManager.await_call("change_coins")


func update_font_color() -> void:
	if red_if_too_expensive and coin_value > Stats.coins and not Engine.is_editor_hint():
		cost_label.label_settings.font_color = Color.RED
	else:
		cost_label.label_settings.font_color = Color.WHITE
