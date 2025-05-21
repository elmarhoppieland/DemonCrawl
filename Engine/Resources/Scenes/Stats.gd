@tool
extends MarginContainer
class_name StatsDisplay

# ==============================================================================
@onready var _life_label: Label = %LifeLabel
@onready var _defense_label: Label = %DefenseLabel
@onready var _coins_label: Label = %CoinsLabel
# ==============================================================================

func get_coin_position() -> Vector2:
	return _coins_label.global_position


func get_heart_position() -> Vector2:
	return _life_label.global_position


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_load_from_current_quest()
	Quest.current_changed.connect(_load_from_current_quest)


func _load_from_current_quest() -> void:
	_update_life_label()
	_update_defense_label()
	_update_coins_label()
	
	if Quest.has_current():
		Quest.get_current().get_stats().changed.connect(func() -> void:
			_update_life_label()
			_update_defense_label()
			_update_coins_label()
		)


func _update_life_label() -> void:
	if not is_node_ready():
		await ready
	if not Quest.has_current():
		return
	
	_life_label.text = "%d/%d" % [Quest.get_current().get_stats().life, Quest.get_current().get_stats().max_life]


func _update_revives() -> void:
	if not is_node_ready():
		await ready
	if not Quest.has_current():
		return
	
	pass # should show/hide revives


func _update_defense_label() -> void:
	if not is_node_ready():
		await ready
	if not Quest.has_current():
		return
	
	_defense_label.text = str(Quest.get_current().get_stats().defense)


func _update_coins_label() -> void:
	if not is_node_ready():
		await ready
	if not Quest.has_current():
		return
	
	_coins_label.text = str(Quest.get_current().get_stats().coins)
