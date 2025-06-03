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
@export var mastery_activations := 0 :
	set(value):
		mastery_activations = value
		emit_changed()
@export var pathfinding := 0 :
	set(value):
		pathfinding = value
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

func get_overview_text() -> String:
	var text := ""
	
	text += "• " + (tr("OVERVIEW_SCORE").format({"score": score})) + "\n" \
		+ "• " + (tr("OVERVIEW_CELLS_OPENED_SINCE_MISTAKE").format({"cells": cells_opened_since_mistake})) + "\n" \
		+ "• " + (tr("OVERVIEW_MORALITY").format({"morality": morality})) + "\n" \
		+ "• " + (tr("OVERVIEW_MASTERY_ACTIVATIONS").format({"activations": mastery_activations})) + "\n"
	
	if chain_length > 1:
		text += "• " + (tr("OVERVIEW_CHAIN_LENGTH").format({"length": chain_length})) + "\n" \
			+ "• " + (tr("OVERVIEW_CHAIN_VALUE").format({"value": chain_value})) + "\n" \
			+ "• " + (tr("OVERVIEW_CHAIN_SUM").format({"sum": chain_length * chain_value})) + "\n"
	
	if pathfinding > 0:
		text += "• " + (tr("OVERVIEW_PATHFINDING").format({"pathfinding": pathfinding})) + "\n"
	
	if not is_equal_approx(rare_loot_modifier, 1.0):
		text += "• " + (tr("OVERVIEW_RARE_LOOT_MODIFIER").format({"modifier": roundi(100 * rare_loot_modifier)})) + "\n"
	
	text += "• " + tr("OVERVIEW_CHESTS_OPENED").format({"chests": chests_opened}) + "\n" \
		+ "• " + tr("OVERVIEW_MONSTERS_KILLED").format({"monsters": monsters_killed}) + "\n"
	
	return text.strip_edges()
