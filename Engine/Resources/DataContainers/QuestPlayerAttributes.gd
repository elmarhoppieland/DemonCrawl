extends Resource
class_name QuestPlayerAttributes

# ==============================================================================
@export var score := 0 :
	set(value):
		score = value
		emit_changed()
@export var cells_opened_since_mistake := 0 :
	set(value):
		cells_opened_since_mistake = value
		emit_changed()
@export var rare_loot_modifier := 1.0 :
	set(value):
		rare_loot_modifier = value
		emit_changed()
@export var morality := 0 :
	set(value):
		morality = value
		emit_changed()
@export var chests_opened := 0 :
	set(value):
		chests_opened = value
		emit_changed()
@export var monsters_killed := 0 :
	set(value):
		monsters_killed = value
		emit_changed()
@export_subgroup("Chain", "chain_")
@export var chain_value := 0 :
	set(value):
		chain_value = value
		emit_changed()
@export var chain_length := 0 :
	set(value):
		chain_length = value
		emit_changed()
# ==============================================================================
