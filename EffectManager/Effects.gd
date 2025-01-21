@tool
extends Object
class_name Effects

# ==============================================================================
static var Signals := __EffectSignals.new()
static var MutableSignals := __EffectSignals.new()
# ==============================================================================

static func change_max_life(max_life: int) -> int:
	max_life = EffectManager.propagate(MutableSignals.change_max_life, [max_life], 0)
	EffectManager.propagate(Signals.change_max_life, [max_life])
	return max_life


static func change_revives(revives: int) -> int:
	revives = EffectManager.propagate(MutableSignals.change_revives, [revives], 0)
	EffectManager.propagate(Signals.change_revives, [revives])
	return revives


static func change_defense(defense: int) -> int:
	defense = EffectManager.propagate(MutableSignals.change_defense, [defense], 0)
	EffectManager.propagate(Signals.change_defense, [defense])
	return defense


static func change_coins(coins: int) -> int:
	coins = EffectManager.propagate(MutableSignals.change_coins, [coins], 0)
	EffectManager.propagate(Signals.change_coins, [coins])
	return coins


static func quest_start() -> void:
	EffectManager.propagate(MutableSignals.quest_start, [])
	EffectManager.propagate(Signals.quest_start, [])


static func quest_finish() -> void:
	EffectManager.propagate(MutableSignals.quest_finish, [])
	EffectManager.propagate(Signals.quest_finish, [])


static func damage(amount: int, source: Object) -> int:
	amount = EffectManager.propagate(MutableSignals.damage, [amount, source], 0)
	EffectManager.propagate(Signals.damage, [amount, source])
	return amount


static func change_life(amount: int, source: Object) -> int:
	amount = EffectManager.propagate(MutableSignals.change_life, [amount, source], 0)
	EffectManager.propagate(Signals.change_life, [amount, source])
	return amount


static func death(source: Object) -> void:
	EffectManager.propagate(MutableSignals.death, [source])
	EffectManager.propagate(Signals.death, [source])


static func player_lose(source: Object) -> void:
	EffectManager.propagate(MutableSignals.player_lose, [source])
	EffectManager.propagate(Signals.player_lose, [source])


static func spend_coins(amount: int, dest: Object) -> int:
	amount = EffectManager.propagate(MutableSignals.spend_coins, [amount, dest], 0)
	EffectManager.propagate(Signals.spend_coins, [amount, dest])
	return amount


static func change_score(score: int) -> int:
	score = EffectManager.propagate(MutableSignals.change_score, [score], 0)
	EffectManager.propagate(Signals.change_score, [score])
	return score


static func change_cells_opened_since_mistake(cells_opened_since_mistake: int) -> int:
	cells_opened_since_mistake = EffectManager.propagate(MutableSignals.change_cells_opened_since_mistake, [cells_opened_since_mistake], 0)
	EffectManager.propagate(Signals.change_cells_opened_since_mistake, [cells_opened_since_mistake])
	return cells_opened_since_mistake


static func change_morality(morality: int) -> int:
	morality = EffectManager.propagate(MutableSignals.change_morality, [morality], 0)
	EffectManager.propagate(Signals.change_morality, [morality])
	return morality


static func change_chests_opened(chests_opened: int) -> int:
	chests_opened = EffectManager.propagate(MutableSignals.change_chests_opened, [chests_opened], 0)
	EffectManager.propagate(Signals.change_chests_opened, [chests_opened])
	return chests_opened


static func change_monsters_killed(monsters_killed: int) -> int:
	monsters_killed = EffectManager.propagate(MutableSignals.change_monsters_killed, [monsters_killed], 0)
	EffectManager.propagate(Signals.change_monsters_killed, [monsters_killed])
	return monsters_killed


static func get_coin_value(value: int, cell: Cell) -> int:
	value = EffectManager.propagate(MutableSignals.get_coin_value, [value, cell], 0)
	EffectManager.propagate(Signals.get_coin_value, [value, cell])
	return value


static func get_diamond_value(value: int, cell: Cell) -> int:
	value = EffectManager.propagate(MutableSignals.get_diamond_value, [value, cell], 0)
	EffectManager.propagate(Signals.get_diamond_value, [value, cell])
	return value


static func get_chest_reward_count(reward_count: int, cell: Cell) -> int:
	reward_count = EffectManager.propagate(MutableSignals.get_chest_reward_count, [reward_count, cell], 0)
	EffectManager.propagate(Signals.get_chest_reward_count, [reward_count, cell])
	return reward_count


static func get_chest_item_max_cost(max_cost: int, cell: Cell) -> int:
	max_cost = EffectManager.propagate(MutableSignals.get_chest_item_max_cost, [max_cost, cell], 0)
	EffectManager.propagate(Signals.get_chest_item_max_cost, [max_cost, cell])
	return max_cost


static func item_use(item: Item) -> void:
	EffectManager.propagate(MutableSignals.item_use, [item])
	EffectManager.propagate(Signals.item_use, [item])


static func get_chest_rewards(rewards: Array[Collectible], cell: Cell) -> Array[Collectible]:
	rewards = EffectManager.propagate(MutableSignals.get_chest_rewards, [rewards, cell], 0)
	EffectManager.propagate(Signals.get_chest_rewards, [rewards, cell])
	return rewards


static func cell_open(cell: Cell) -> void:
	EffectManager.propagate(MutableSignals.cell_open, [cell])
	EffectManager.propagate(Signals.cell_open, [cell])


static func item_gain(item: Item) -> void:
	EffectManager.propagate(MutableSignals.item_gain, [item])
	EffectManager.propagate(Signals.item_gain, [item])


static func inventory_add_item(item: Item) -> void:
	EffectManager.propagate(MutableSignals.inventory_add_item, [item])
	EffectManager.propagate(Signals.inventory_add_item, [item])


static func item_lose(item: Item) -> void:
	EffectManager.propagate(MutableSignals.item_lose, [item])
	EffectManager.propagate(Signals.item_lose, [item])


static func get_string_table(table: StringTable, name: String) -> StringTable:
	table = EffectManager.propagate(MutableSignals.get_string_table, [table, name], 0)
	EffectManager.propagate(Signals.get_string_table, [table, name])
	return table


static func get_shop_item_count(item_count: int) -> int:
	item_count = EffectManager.propagate(MutableSignals.get_shop_item_count, [item_count], 0)
	EffectManager.propagate(Signals.get_shop_item_count, [item_count])
	return item_count


static func bury_bones(cell: Cell) -> void:
	EffectManager.propagate(MutableSignals.bury_bones, [cell])
	EffectManager.propagate(Signals.bury_bones, [cell])


static func restore_life(life: int, source: Object) -> int:
	life = EffectManager.propagate(MutableSignals.restore_life, [life, source], 0)
	EffectManager.propagate(Signals.restore_life, [life, source])
	return life


static func lose_life(life: int, source: Object) -> int:
	life = EffectManager.propagate(MutableSignals.lose_life, [life, source], 0)
	EffectManager.propagate(Signals.lose_life, [life, source])
	return life


static func gain_mana(mana: int, source: Object) -> int:
	mana = EffectManager.propagate(MutableSignals.gain_mana, [mana, source], 0)
	EffectManager.propagate(Signals.gain_mana, [mana, source])
	return mana


static func object_revealed(object: CellObject, active: bool) -> void:
	EffectManager.propagate(MutableSignals.object_revealed, [object, active])
	EffectManager.propagate(Signals.object_revealed, [object, active])


static func get_heart_value(value: int = 1) -> int:
	value = EffectManager.propagate(MutableSignals.get_heart_value, [value], 0)
	EffectManager.propagate(Signals.get_heart_value, [value])
	return value
