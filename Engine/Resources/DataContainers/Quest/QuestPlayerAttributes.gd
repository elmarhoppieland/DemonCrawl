extends Node
class_name QuestPlayerAttributes

# ==============================================================================
const RESEARCH_WEIGHT_MULT := 5.0
# ==============================================================================
@export var score := 0 :
	set(value):
		score = EffectManager.propagate(change_property, [&"score", value], 1)
		EffectManager.propagate(property_changed, [&"score", score])
		emit_changed()
@export var cells_opened_since_mistake := 0 :
	set(value):
		cells_opened_since_mistake = EffectManager.propagate(change_property, [&"cells_opened_since_mistake", value], 1)
		EffectManager.propagate(property_changed, [&"cells_opened_since_mistake", score])
		emit_changed()
@export var rare_loot_modifier := 1.0 :
	set(value):
		rare_loot_modifier = EffectManager.propagate(change_property, [&"rare_loot_modifier", value], 1)
		EffectManager.propagate(property_changed, [&"rare_loot_modifier", score])
		emit_changed()
@export var morality := 0 :
	set(value):
		morality = EffectManager.propagate(change_property, [&"morality", value], 1)
		EffectManager.propagate(property_changed, [&"morality", score])
		emit_changed()
@export var chests_opened := 0 :
	set(value):
		chests_opened = EffectManager.propagate(change_property, [&"chests_opened", value], 1)
		EffectManager.propagate(property_changed, [&"chests_opened", score])
		emit_changed()
@export var monsters_killed := 0 :
	set(value):
		monsters_killed = EffectManager.propagate(change_property, [&"monsters_killed", value], 1)
		EffectManager.propagate(property_changed, [&"monsters_killed", score])
		emit_changed()
@export var mastery_activations := 0 :
	set(value):
		mastery_activations = EffectManager.propagate(change_property, [&"mastery_activations", value], 1)
		EffectManager.propagate(property_changed, [&"mastery_activations", score])
		emit_changed()
@export var pathfinding := 0 :
	set(value):
		pathfinding = EffectManager.propagate(change_property, [&"pathfinding", value], 1)
		EffectManager.propagate(property_changed, [&"pathfinding", score])
		emit_changed()
@export var powerchording := 0 :
	set(value):
		powerchording = EffectManager.propagate(change_property, [&"powerchording", value], 1)
		EffectManager.propagate(property_changed, [&"powerchording", score])
		emit_changed()
@export_subgroup("Chain", "chain_")
@export var chain_value := 0 :
	set(value):
		chain_value = EffectManager.propagate(change_property, [&"chain_value", value], 1)
		EffectManager.propagate(property_changed, [&"chain_value", score])
		emit_changed()
@export var chain_length := 0 :
	set(value):
		chain_length = EffectManager.propagate(change_property, [&"chain_length", value], 1)
		EffectManager.propagate(property_changed, [&"chain_length", score])
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
		text += "• " + (tr("stats.overview.pathfinding").format({"powerchording": powerchording})) + "\n"
	
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
