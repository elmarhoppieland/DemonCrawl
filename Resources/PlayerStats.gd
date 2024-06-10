extends StaticClass
class_name PlayerStats

# ==============================================================================
static var score: int = SavesManager.get_value("score", PlayerStats, 0)
static var cells_opened_since_mistake: int = SavesManager.get_value("cells_opened_since_mistake", PlayerStats, 0)
static var morality: int = SavesManager.get_value("morality", PlayerStats, 0)
static var chain: ChainData = SavesManager.get_value("chain", PlayerStats, null)
static var chests_opened: int = SavesManager.get_value("chests_opened", PlayerStats, 0)
static var monsters_killed: int = SavesManager.get_value("monsters_killed", PlayerStats, 0)
static var pathfinding: int = SavesManager.get_value("pathfinding", PlayerStats, 0)
# ==============================================================================

static func get_stats_tooltip_text() -> String:
	const BULLET := "[img]Assets/sprites/bullet.png[/img] "
	
	var text := ""
	
	text += BULLET + "%s: %d %s" % [Translator.tr("SCORE"), score, Translator.tr("POINTS_ABBR")]
	text += "\n" + BULLET + "%s: %d" % [Translator.tr("CELLS_OPENED_SINCE_MISTAKE"), cells_opened_since_mistake]
	text += "\n" + BULLET + "%s: %d" % [Translator.tr("MORALITY"), morality]
	
	if chain and chain.length > 1:
		text += "\n" + BULLET + "%s: %d %s" % [Translator.tr("CHAIN_LENGTH"), chain.length, Translator.tr("TURNS")]
		text += "\n" + BULLET + "%s: %d" % [Translator.tr("CHAIN_VALUE"), chain.value]
		text += "\n" + BULLET + "%s: %d" % [Translator.tr("CHAIN_SUM"), chain.get_sum()]
	
	text += "\n" + BULLET + "%s: %d" % [Translator.tr("CHESTS_OPENED"), chests_opened]
	text += "\n" + BULLET + "%s: %d" % [Translator.tr("MONSTERS_KILLED"), monsters_killed]
	
	return text


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
