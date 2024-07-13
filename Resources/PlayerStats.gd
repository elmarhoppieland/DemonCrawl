extends StaticClass
class_name PlayerStats

# ==============================================================================
static var score: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("score", value)
		score = value
static var cells_opened_since_mistake: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("cells_opened_since_mistake", value)
		cells_opened_since_mistake = value
static var morality: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("morality", value)
		morality = value
static var chain: ChainData = Eternal.create(null)
static var chests_opened: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("chests_opened", value)
		chests_opened = value
static var monsters_killed: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("monsters_killed", value)
		monsters_killed = value
static var pathfinding: int = Eternal.create(0) :
	set(value):
		value = EffectManager.change_stat("pathfinding", value)
		pathfinding = value
# ==============================================================================

static func get_stats_tooltip_text() -> String:
	var parts := PackedStringArray([
		"%s: %d %s" % [TranslationServer.tr("SCORE"), score, TranslationServer.tr("POINTS_ABBR")],
		"%s: %d" % [TranslationServer.tr("CELLS_OPENED_SINCE_MISTAKE"), cells_opened_since_mistake],
		"%s: %d" % [TranslationServer.tr("MORALITY"), morality]
	])
	
	if chain and chain.length > 1:
		parts.append_array([
			"%s: %d %s" % [TranslationServer.tr("CHAIN_LENGTH"), chain.length, TranslationServer.tr("TURNS")],
			"%s: %d" % [TranslationServer.tr("CHAIN_VALUE"), chain.value],
			"%s: %d" % [TranslationServer.tr("CHAIN_SUM"), chain.get_sum()]
		])
	
	parts.append_array([
		"%s: %d" % [TranslationServer.tr("CHESTS_OPENED"), chests_opened],
		"%s: %d" % [TranslationServer.tr("MONSTERS_KILLED"), monsters_killed]
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


static func reset() -> void:
	score = 0
	cells_opened_since_mistake = 0
	morality = 0
	chain = null
	chests_opened = 0
	monsters_killed = 0
	pathfinding = 0


class ChainData:
	var length := 0
	var value := 0
	
	func get_sum() -> int:
		return length * value
