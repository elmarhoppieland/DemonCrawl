extends StaticClass
class_name PlayerStats

# ==============================================================================
static var score: int = SavesManager.get_value("score", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("score", value)
		score = value
static var cells_opened_since_mistake: int = SavesManager.get_value("cells_opened_since_mistake", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("cells_opened_since_mistake", value)
		score = value
static var morality: int = SavesManager.get_value("morality", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("morality", value)
		score = value
static var chain: ChainData = SavesManager.get_value("chain", PlayerStats, null)
static var chests_opened: int = SavesManager.get_value("chests_opened", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("chests_opened", value)
		score = value
static var monsters_killed: int = SavesManager.get_value("monsters_killed", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("monsters_killed", value)
		score = value
static var pathfinding: int = SavesManager.get_value("pathfinding", PlayerStats, 0) :
	set(value):
		value = EffectManager.change_stat("pathfinding", value)
		score = value
# ==============================================================================

static func get_stats_tooltip_text() -> String:
	var parts := PackedStringArray([
		"%s: %d %s" % [Translator.tr("SCORE"), score, Translator.tr("POINTS_ABBR")],
		"%s: %d" % [Translator.tr("CELLS_OPENED_SINCE_MISTAKE"), cells_opened_since_mistake],
		"%s: %d" % [Translator.tr("MORALITY"), morality]
	])
	
	if chain and chain.length > 1:
		parts.append_array([
			"%s: %d %s" % [Translator.tr("CHAIN_LENGTH"), chain.length, Translator.tr("TURNS")],
			"%s: %d" % [Translator.tr("CHAIN_VALUE"), chain.value],
			"%s: %d" % [Translator.tr("CHAIN_SUM"), chain.get_sum()]
		])
	
	parts.append_array([
		"%s: %d" % [Translator.tr("CHESTS_OPENED"), chests_opened],
		"%s: %d" % [Translator.tr("MONSTERS_KILLED"), monsters_killed]
	])
	
	return "• " + "\n• ".join(parts)


static func process_chain(value: int) -> void:
	if not chain:
		chain = ChainData.new()
	
	if chain.value == value:
		chain.length += 1
	else:
		chain.value = value
		chain.length = 1


class ChainData:
	var length := 0
	var value := 0
	
	func get_sum() -> int:
		return length * value


static func _export_chain() -> Dictionary:
	if not chain:
		return {}
	
	return {
		"length": chain.length,
		"value": chain.value
	}


static func _import_chain(value: Dictionary) -> ChainData:
	if value.is_empty():
		return null
	
	var data := ChainData.new()
	data.length = value.length
	data.value = value.value
	return data
