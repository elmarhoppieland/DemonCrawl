@tool
extends Object
class_name Effects

# ==============================================================================
static var Signals := __EffectSignals.new()
static var MutableSignals := __EffectSignals.new()
# ==============================================================================

static func board_permissions_changed() -> void: ## Called when the [Board] permissions change.[br][br]Useful to react to the timer pausing/resuming.
	EffectManager.propagate(MutableSignals.board_permissions_changed, [])
	EffectManager.propagate(Signals.board_permissions_changed, [])


static func bury_bones(cell: Cell) -> void: ## Called when the player buries bones in a [Cell].
	EffectManager.propagate(MutableSignals.bury_bones, [cell])
	EffectManager.propagate(Signals.bury_bones, [cell])


static func get_aura_color(default: Color, aura: String, cell: Cell) -> Color: ## Returns the color of a [Cell]'s aura.[br][br]Should return a [Color] override or the [code]default[/code] argument.
	default = EffectManager.propagate(MutableSignals.get_aura_color, [default, aura, cell], 0)
	EffectManager.propagate(Signals.get_aura_color, [default, aura, cell])
	return default


static func turn() -> void: ## Called when the player passes a turn.[br][br]Called multiple times if the player uses a "turn pass" effect.
	EffectManager.propagate(MutableSignals.turn, [])
	EffectManager.propagate(Signals.turn, [])


static func cell_open(cell: Cell) -> void: ## Cell when a [Cell] is opened.
	EffectManager.propagate(MutableSignals.cell_open, [cell])
	EffectManager.propagate(Signals.cell_open, [cell])


static func cell_get_mana(default: int, cell: Cell) -> int: ## Returns how much [code]mana[/code] a [Cell] gives.[br][br]Should return a mana override or the [code]default[/code] argument.
	default = EffectManager.propagate(MutableSignals.cell_get_mana, [default, cell], 0)
	EffectManager.propagate(Signals.cell_get_mana, [default, cell])
	return default


static func get_chest_reward_count(default: int = 1, cell: Cell = null) -> int: ## Returns the number of rewards a chest gives.
	default = EffectManager.propagate(MutableSignals.get_chest_reward_count, [default, cell], 0)
	EffectManager.propagate(Signals.get_chest_reward_count, [default, cell])
	return default


static func get_chest_item_max_cost(default: int, cell: Cell = null) -> int: ## Returns the maximum cost of items that can be found in a chest.
	default = EffectManager.propagate(MutableSignals.get_chest_item_max_cost, [default, cell], 0)
	EffectManager.propagate(Signals.get_chest_item_max_cost, [default, cell])
	return default


static func player_lose(source: Object) -> void: ## Called when the player loses.[br][br]Called after [method death], and [method Stats.revive] cannot be called here.
	EffectManager.propagate(MutableSignals.player_lose, [source])
	EffectManager.propagate(Signals.player_lose, [source])


static func get_diamond_value(default: int, cell: Cell = null) -> int: ## Returns the value of a diamond.
	default = EffectManager.propagate(MutableSignals.get_diamond_value, [default, cell], 0)
	EffectManager.propagate(Signals.get_diamond_value, [default, cell])
	return default


static func get_coin_value(default: int = 1, cell: Cell = null) -> int: ## Returns the value of a coin.
	default = EffectManager.propagate(MutableSignals.get_coin_value, [default, cell], 0)
	EffectManager.propagate(Signals.get_coin_value, [default, cell])
	return default


static func stage_leave() -> void: ## Called when the player leaves a [Stage]. The left stage can be retrieved using [code]Quest.get_current_stage()[/code].
	EffectManager.propagate(MutableSignals.stage_leave, [])
	EffectManager.propagate(Signals.stage_leave, [])


static func mistake() -> void: ## Called when the player makes a mistake, i.e. clicked on a monster.
	EffectManager.propagate(MutableSignals.mistake, [])
	EffectManager.propagate(Signals.mistake, [])


static func stage_enter() -> void: ## Called when the player enters a [Stage]. The stage can be retrieved using [code]Quest.get_current_stage()[/code].
	EffectManager.propagate(MutableSignals.stage_enter, [])
	EffectManager.propagate(Signals.stage_enter, [])


static func board_loaded() -> void: ## Called when the [Board] is loaded.
	EffectManager.propagate(MutableSignals.board_loaded, [])
	EffectManager.propagate(Signals.board_loaded, [])


static func board_begin() -> void: ## Called when the player opens the first [Cell].
	EffectManager.propagate(MutableSignals.board_begin, [])
	EffectManager.propagate(Signals.board_begin, [])


static func stage_load() -> void: ## Called when the current [Stage] has been loaded.
	EffectManager.propagate(MutableSignals.stage_load, [])
	EffectManager.propagate(Signals.stage_load, [])


static func get_string_table(default: StringTable, table_name: String) -> Object: ## Returns the string table with the given [code]table_name[/code].
	default = EffectManager.propagate(MutableSignals.get_string_table, [default, table_name], 0)
	EffectManager.propagate(Signals.get_string_table, [default, table_name])
	return default


static func quest_start() -> void: ## Called when the player starts a new quest.
	EffectManager.propagate(MutableSignals.quest_start, [])
	EffectManager.propagate(Signals.quest_start, [])


static func quest_finish() -> void: ## Called when the player finishes a quest.
	EffectManager.propagate(MutableSignals.quest_finish, [])
	EffectManager.propagate(Signals.quest_finish, [])


static func change_score(score: int) -> int: ## Called when the player's score changes.[br][br]Mutable connections can change the score by returning another value. The value before changing is still in [member PlayerStats.score].
	score = EffectManager.propagate(MutableSignals.change_score, [score], 0)
	EffectManager.propagate(Signals.change_score, [score])
	return score


static func change_cells_opened_since_mistake(new_argument: int) -> int: ## Called when the player's amount of cells opened since the last mistake changes.[br][br]Mutable connections can change the stat by returning another value. The value before changing is still in [member PlayerStats.cells_opened_since_mistake].
	new_argument = EffectManager.propagate(MutableSignals.change_cells_opened_since_mistake, [new_argument], 0)
	EffectManager.propagate(Signals.change_cells_opened_since_mistake, [new_argument])
	return new_argument


static func change_morality(morality: int) -> int: ## Called when the player's morality changes.[br][br]Mutable connections can change the morality by returning another value. The value before changing is still in [member PlayerStats.morality].
	morality = EffectManager.propagate(MutableSignals.change_morality, [morality], 0)
	EffectManager.propagate(Signals.change_morality, [morality])
	return morality


static func change_chests_opened(chests_opened: int) -> int: ## Called when the player's number of opened chests changes.[br][br]Mutable connections can change the stat by returning another value. The value before changing is still in [member PlayerStats.chests_opened].
	chests_opened = EffectManager.propagate(MutableSignals.change_chests_opened, [chests_opened], 0)
	EffectManager.propagate(Signals.change_chests_opened, [chests_opened])
	return chests_opened


static func change_monsters_killed(monsters_killed: int) -> int: ## Called when the player's number of killed monsters changes.[br][br]Mutable connections can change the stat by returning another value. The value before changing is still in [member PlayerStats.monsters_killed].
	monsters_killed = EffectManager.propagate(MutableSignals.change_monsters_killed, [monsters_killed], 0)
	EffectManager.propagate(Signals.change_monsters_killed, [monsters_killed])
	return monsters_killed


static func change_pathfinding(pathfinding: int) -> int: ## Called when the player's pathfinding changes.[br][br]Mutable connections can change the pathfinding by returning another value. The value before changing is still in [member PlayerStats.pathfinding].
	pathfinding = EffectManager.propagate(MutableSignals.change_pathfinding, [pathfinding], 0)
	EffectManager.propagate(Signals.change_pathfinding, [pathfinding])
	return pathfinding


static func item_use(new_argument: Object) -> void: ## Called when the player uses an item.
	EffectManager.propagate(MutableSignals.item_use, [new_argument])
	EffectManager.propagate(Signals.item_use, [new_argument])


static func parse_icon_atlas(atlas: AtlasTexture, name: String) -> AtlasTexture: ## Called when parsing the [AtlasTexture] with all icons. Return a non-[code]null[/code] value to override the atlas.
	atlas = EffectManager.propagate(MutableSignals.parse_icon_atlas, [atlas, name], 0)
	EffectManager.propagate(Signals.parse_icon_atlas, [atlas, name])
	return atlas


static func parse_icon_rect(rect: Rect2i, name: String) -> Rect2i: ## Called when determining an icon's texture. Return a non-[code]null[/code] value to override the region.
	rect = EffectManager.propagate(MutableSignals.parse_icon_rect, [rect, name], 0)
	EffectManager.propagate(Signals.parse_icon_rect, [rect, name])
	return rect


static func change_coins(coins: int) -> int: ## Called when the player's coins change.[br][br]Mutable connections can change the value by returning another value.
	coins = EffectManager.propagate(MutableSignals.change_coins, [coins], 0)
	EffectManager.propagate(Signals.change_coins, [coins])
	return coins


static func get_shop_item_count(default: int = 0) -> int: ## Returns the number of items in an item shop.
	default = EffectManager.propagate(MutableSignals.get_shop_item_count, [default], 0)
	EffectManager.propagate(Signals.get_shop_item_count, [default])
	return default


static func change_max_life(max_life: int) -> int: ## Called when the player's max life changes.[br][br]Mutable connections can change the value by returning another value.
	max_life = EffectManager.propagate(MutableSignals.change_max_life, [max_life], 0)
	EffectManager.propagate(Signals.change_max_life, [max_life])
	return max_life


static func change_revives(revives: int) -> int: ## Called when the player's number of revives changes.[br][br]Mutable connections can change the value by returning another value.
	revives = EffectManager.propagate(MutableSignals.change_revives, [revives], 0)
	EffectManager.propagate(Signals.change_revives, [revives])
	return revives


static func change_defense(defense: int) -> int: ## Called when the player's defense changes.[br][br]Mutable connections can change the value by returning another value.
	defense = EffectManager.propagate(MutableSignals.change_defense, [defense], 0)
	EffectManager.propagate(Signals.change_defense, [defense])
	return defense


static func damage(amount: int, source: Object) -> int: ## Called when the player takes damage.[br][br]Mutable connections can change the amount of damage by returning another value.
	amount = EffectManager.propagate(MutableSignals.damage, [amount, source], 0)
	EffectManager.propagate(Signals.damage, [amount, source])
	return amount


static func change_life(life: int, source: Object) -> int: ## Called when the player's number of lives changes.[br][br]Mutable connections can change the value by returning another value.
	life = EffectManager.propagate(MutableSignals.change_life, [life, source], 0)
	EffectManager.propagate(Signals.change_life, [life, source])
	return life


static func death(source: Object) -> void: ## Called when the player dies.[br][br][method Stats.revive] can be called during connections to prevent the death. Connections with lower priority will still be called, and the player will use a revive without lowering the number of revives.
	EffectManager.propagate(MutableSignals.death, [source])
	EffectManager.propagate(Signals.death, [source])


static func spend_coins(amount: int, destination: Object) -> int: ## Called when the player spends coins.[br][br]Mutable connections can return another value to change the cost of the destination.[br][br][b]Note:[/b] Losing coins is not the same as spending coins. If coins are lost, this effect is not called. However, after this effect is called, [method change_coins] will be called.
	amount = EffectManager.propagate(MutableSignals.spend_coins, [amount, destination], 0)
	EffectManager.propagate(Signals.spend_coins, [amount, destination])
	return amount


static func item_gain(item: Item) -> void: ## Called when the player gains a new item.
	EffectManager.propagate(MutableSignals.item_gain, [item])
	EffectManager.propagate(Signals.item_gain, [item])


static func inventory_add_item(item: Item) -> void: ## Called when an item is added to the inventory, either after gaining it or when reloading the inventory.
	EffectManager.propagate(MutableSignals.inventory_add_item, [item])
	EffectManager.propagate(Signals.inventory_add_item, [item])


static func item_lose(item: Item) -> void: ## Called when an item is permanently lost.
	EffectManager.propagate(MutableSignals.item_lose, [item])
	EffectManager.propagate(Signals.item_lose, [item])


static func get_chest_rewards(default: Array[Collectible]) -> Array[Collectible]:
	default = EffectManager.propagate(MutableSignals.spend_coins, [default], 0)
	EffectManager.propagate(Signals.spend_coins, [default])
	return default


static func get_board_permissions(default: int, state: Board.State) -> int:
	default = EffectManager.propagate(MutableSignals.spend_coins, [default, state], 0)
	EffectManager.propagate(Signals.spend_coins, [default, state])
	return default
