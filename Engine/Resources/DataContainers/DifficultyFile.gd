extends Resource
class_name Difficulty

# ==============================================================================
@export var name := ""  ## The name of the difficulty.
@export var icon: Texture2D = null  ## The icon of the difficulty.

@export var conditions: PackedStringArray = []

@export var quests: Array[QuestFile] = []  ## This difficulty's quests.

@export_group("Starting Stats")
@export var max_life := 5  ## The amount of max lives the player should start each quest with.
@export var life := 5  ## The amount of lives the player should start each quest with. Should never be higher than [property max_life].
@export var revives := 0  ## The number of revives the player should start each quest with.
@export var defense := 0  ## The amount of defense the player should start each quest with.
@export var coins := 0  ## The amount of coins the player should start each quest with.
# ==============================================================================

func apply_starting_values(quest: Quest) -> void:
	quest.get_stats().max_life = max_life
	quest.get_stats().life = life
	quest.get_stats().revives = revives
	quest.get_stats().defense = defense
	quest.get_stats().coins = coins


func is_unlocked() -> bool:
	for condition in conditions:
		if condition.begins_with("!") == PlayerFlags.has_flag(condition.trim_prefix("!")):
			return false
	
	return true
