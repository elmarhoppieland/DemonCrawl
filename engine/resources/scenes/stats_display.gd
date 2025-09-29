@tool
extends MarginContainer
class_name StatsDisplay

# ==============================================================================
@export var stats: QuestStats = null :
	set(value):
		if stats and stats.changed.is_connected(_update):
			stats.changed.disconnect(_update)
		
		stats = value
		
		_update()
		if value and not value.changed.is_connected(_update):
			value.changed.connect(_update)
# ==============================================================================
@onready var _revive_texture_rect: TextureRect = %ReviveTextureRect
@onready var _life_label: Label = %LifeLabel
@onready var _defense_label: Label = %DefenseLabel
@onready var _coins_label: Label = %CoinsLabel
# ==============================================================================

func get_coin_position() -> Vector2:
	return _coins_label.global_position


func get_heart_position() -> Vector2:
	return _life_label.global_position


func _update() -> void:
	if not is_node_ready():
		await ready
	
	if not stats:
		_life_label.text = "-/-"
		_revive_texture_rect.hide()
		_defense_label.text = "-"
		_coins_label.text = "-"
		return
	
	_life_label.text = "%d/%d" % [stats.life, stats.max_life]
	_revive_texture_rect.visible = stats.revives > 0
	_defense_label.text = str(stats.defense)
	_coins_label.text = str(stats.coins)
