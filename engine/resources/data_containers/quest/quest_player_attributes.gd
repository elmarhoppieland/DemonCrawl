extends Node
class_name QuestPlayerAttributes

# ==============================================================================
const RESEARCH_WEIGHT_MULT := 5.0
# ==============================================================================
@export var score := 0 :
	set(value):
		score = EffectManager.propagate_mutable(change_property, 1, &"score", value)
		EffectManager.propagate(property_changed, &"score", score)
		emit_changed()
@export var cells_opened_since_mistake := 0 :
	set(value):
		cells_opened_since_mistake = EffectManager.propagate_mutable(change_property, 1, &"cells_opened_since_mistake", value)
		EffectManager.propagate(property_changed, &"cells_opened_since_mistake", score)
		emit_changed()
@export var rare_loot_modifier := 1.0 :
	set(value):
		rare_loot_modifier = EffectManager.propagate_mutable(change_property, 1, &"rare_loot_modifier", value)
		EffectManager.propagate(property_changed, &"rare_loot_modifier", score)
		emit_changed()
@export var morality := 0 :
	set(value):
		morality = EffectManager.propagate_mutable(change_property, 1, &"morality", value)
		EffectManager.propagate(property_changed, &"morality", score)
		emit_changed()
@export var chests_opened := 0 :
	set(value):
		chests_opened = EffectManager.propagate_mutable(change_property, 1, &"chests_opened", value)
		EffectManager.propagate(property_changed, &"chests_opened", score)
		emit_changed()
@export var monsters_killed := 0 :
	set(value):
		monsters_killed = EffectManager.propagate_mutable(change_property, 1, &"monsters_killed", value)
		EffectManager.propagate(property_changed, &"monsters_killed", score)
		emit_changed()
@export var mastery_activations := 0 :
	set(value):
		mastery_activations = EffectManager.propagate_mutable(change_property, 1, &"mastery_activations", value)
		EffectManager.propagate(property_changed, &"mastery_activations", score)
		emit_changed()
@export var pathfinding := 0 :
	set(value):
		pathfinding = EffectManager.propagate_mutable(change_property, 1, &"pathfinding", value)
		EffectManager.propagate(property_changed, &"pathfinding", score)
		emit_changed()
@export var powerchording := 0 :
	set(value):
		powerchording = EffectManager.propagate_mutable(change_property, 1, &"powerchording", value)
		EffectManager.propagate(property_changed, &"powerchording", score)
		emit_changed()
@export_subgroup("Chain", "chain_")
@export var chain_value := 0 :
	set(value):
		chain_value = EffectManager.propagate_mutable(change_property, 1, &"chain_value", value)
		EffectManager.propagate(property_changed, &"chain_value", score)
		emit_changed()
@export var chain_length := 0 :
	set(value):
		chain_length = EffectManager.propagate_mutable(change_property, 1, &"chain_length", value)
		EffectManager.propagate(property_changed, &"chain_length", score)
		emit_changed()

@export var research_subject := "" :
	set(value):
		research_subject = value
		emit_changed()
# ==============================================================================
signal changed()

signal change_property(property: StringName, value: Variant)
signal property_changed(property: StringName, value: Variant)
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_overview_text() -> String:
	var text := ""
	
	text += "• " + (tr("stats.overview.score").format({"score": score})) + "\n" \
		+ "• " + (tr("stats.overview.cells-opened-since-mistake").format({"cells": cells_opened_since_mistake})) + "\n" \
		+ "• " + (tr("stats.overview.morality").format({"morality": morality})) + "\n" \
		+ "• " + (tr("stats.overview.mastery-activations").format({"activations": mastery_activations})) + "\n"
	
	if chain_length > 1:
		text += "• " + (tr("stats.overview.chain.length").format({"length": chain_length})) + "\n" \
			+ "• " + (tr("stats.overview.chain.value").format({"value": chain_value})) + "\n" \
			+ "• " + (tr("stats.overview.chain.sum").format({"sum": chain_length * chain_value})) + "\n"
	
	if pathfinding > 0:
		text += "• " + (tr("stats.overview.pathfinding").format({"pathfinding": pathfinding})) + "\n"
	if powerchording > 0:
		text += "• " + (tr("stats.overview.powerchording").format({"powerchording": powerchording})) + "\n"
	
	if not is_equal_approx(rare_loot_modifier, 1.0):
		text += "• " + (tr("stats.overview.rare-loot-modifier").format({"modifier": roundi(100 * rare_loot_modifier)})) + "\n"
	
	text += "• " + tr("stats.overview.chests-opened").format({"chests": chests_opened}) + "\n" \
		+ "• " + tr("stats.overview.monsters-killed").format({"monsters": monsters_killed}) + "\n"
	
	if not research_subject.is_empty():
		text += "\n" + tr("stats.overview.research-subject").format({"subject": tr("research." + research_subject.to_snake_case().to_lower().replace("_", "-")).to_upper()})
	
	return text.strip_edges()


func _ready() -> void:
	get_quest().get_item_pool().add_modifier(func(item: ItemData) -> float:
		if research_subject.is_empty():
			return 1.0
		
		var locale := TranslationServer.get_locale()
		TranslationServer.set_locale("en")
		var description := TranslationServer.translate(item.description)
		TranslationServer.set_locale(locale)
		if research_subject.to_lower() in description.to_lower():
			return RESEARCH_WEIGHT_MULT
		return 1.0
	)


## Returns whether the current [member research_subject] matches the given [ItemData].
## [br][br][b]Note:[/b] This method temporarily changes the locale, so use this sparingly.
func item_matches_research(item: ItemData) -> bool:
	var locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	var description := TranslationServer.translate(item.description)
	TranslationServer.set_locale(locale)
	return research_subject.to_lower() in description.to_lower()


func reset_cells_counter(_cell: CellData):
	cells_opened_since_mistake = 0


func increment_cells_counter(_cell: CellData):
	cells_opened_since_mistake += 1
