@tool
extends Control
class_name ChestCoinsPopup

# ==============================================================================
@export var coins := 0 :
	set(value):
		coins = value
		if not is_node_ready():
			await ready
		_coin_value.coin_value = value
		_string_table_label.generate({ "coins": coins })
# ==============================================================================
@onready var _coin_value: CoinValue = %CoinValue
@onready var _string_table_label: StringTableLabel = %StringTableLabel
# ==============================================================================
