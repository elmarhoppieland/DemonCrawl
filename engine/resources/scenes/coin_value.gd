@tool
extends HBoxContainer
class_name CoinValue

# ==============================================================================
@export var coin_value := 0 :
	set(value):
		coin_value = value
		
		if not is_node_ready():
			await ready
		
		cost_label.text = prefix + str(value)
@export var color := Color.WHITE :
	set(value):
		color = value
		
		if not is_node_ready():
			await ready
		
		cost_label.label_settings.font_color = value
@export var prefix := "" :
	set(value):
		prefix = value
		
		if not is_node_ready():
			await ready
		
		cost_label.text = value + str(coin_value)
# ==============================================================================
@onready var cost_label: Label = %CostLabel
# ==============================================================================
