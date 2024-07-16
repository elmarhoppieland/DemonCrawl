extends StaticClass
class_name EffectDocs

## Documentation for all available Effects.
##
## Below are all available effects. There are a few things to note:
## [br][br][b]1.[/b] There are 2 types of effects: Reactive effects and Influencing effects.
## [br]Reactive effects are called whenever the player does something, e.g. opening a chest.
## These effects never return a value.
## [br]Influencing effects are called whenever determining a value, e.g. when determining the
## amount of rewards in a chest. The first parameter is the currently used value. When returning
## this value, the effect does not influence the value.
## [br][br][b]2.[/b] The value passed into influencing effects (the first parameter) may not be the
## final value being used. This is because other influencing effects may be called afterwards,
## changing the value.
## [br][br][b]3.[/b] Influencing effects can be turned into reactive effects by making them return
## [code]void[/code]. This will make them be called after all influencing effects are called,
## so the value passed into the call (the first parameter) will be the final value being used.
## [br][br][b]4.[/b] When connecting to an effect using [method EffectManager.register_object],
## they may be defined using fewer arguments. If, for example, an effect takes in 2 arguments,
## and the connection is defined with only 1 argument, then only the first argument will be
## passed into the call. To make this work on connections with [method EffectManager.connect_effect],
## use the return value of the connection and call [code]set_total_arg_count()[/code]
## to specify the number of arguments in the function that is connected.

# ==============================================================================

## Called when burying bones in the given [Cell].
@warning_ignore("unused_parameter")
func bury_bones(cell: Cell) -> void:
	pass


## Called when determining a cell's aura color. The provided [code]color[/code] is
## the currently used value for color. Return this value to not change the aura.
## Return a different value to change the [Color] used for this aura.
@warning_ignore("unused_parameter")
func get_aura_color(color: Color, aura: String, cell: Cell) -> Color:
	return color


## Called whenever the player opens one or more cells, or when the player passes a turn.
func turn() -> void:
	pass


## Called when the player opens a cell, either directly by clicking on this cell,
## by chording a nearby cell, or by using an [Item].
@warning_ignore("unused_parameter")
func cell_open(cell: Cell) -> void:
	pass


## Called when a cell gives mana, typically when opening the cell. Returns the amount
## of mana the cell gives.
@warning_ignore("unused_parameter")
func cell_get_mana(mana: int, cell: Cell) -> int:
	return mana


## Called when determining the number of rewards in an item chest. [code]count[/code]
## is the currently used value. Return this value to not change the number of rewards.
func get_chest_reward_count(count: int) -> int:
	return count


## Called when determining the rewards an item chest gives. [code]rewards[/code] will contain
## the chest's items. The [Array] can safely be modified.
func get_chest_rewards(rewards: Array[Collectible]) -> Array[Collectible]:
	return rewards


## Called when determining the maximum cost of items in an item chest. [code]max_cost[/code]
## is the currently used value. Return this value to not change maximum cost.
func get_chest_item_max_cost(max_cost: int) -> int:
	return max_cost


## Called when determining the value of a coin. [code]value[/code] is the currently
## used value. Return this value to not change the value of a coin.
func get_coin_value(value: int) -> int:
	return value


## Called when the player enters a stage. This is called before [method board_loaded],
## when the [Board]'s properties have not been initialized and can therefore be changed
## by changing the current stage's properties.
func stage_enter() -> void:
	pass


## Called when the player loads or reloads a stage. This is called after [method stage_enter],
## when the [Board]'s properties have been initialized. Changing the stage's properties
## may not change the board's properties.
func board_loaded() -> void:
	pass


## Called when the player loads a stage. This is called after [method board_begin],
## if this is the first time the player loads this stage.
func stage_load() -> void:
	pass


## Called when the player begins the board (this is always after calling [method stage_enter]).
func board_begin() -> void:
	pass


## Called when the board's permissions change.
func board_permissions_changed() -> void:
	pass


## Called when the player starts a new quest.
func quest_start() -> void:
	pass


## Called when the player finishes a quest. Not called if the player lost the quest.
func quest_finish() -> void:
	pass


## Called when the player uses an [Item]. The item may or may not be consumed by this action.
@warning_ignore("unused_parameter")
func item_use(item: Item) -> void:
	pass


## Called when determining the number of items in a shop. [code]count[/code] is
## the currently used value. Return this value to not change the number of items.
func get_shop_item_count(count: int) -> int:
	return count


## Called when the player takes damage. [code]amount[/code] is the currently used value.
## Return this value to not change the amount of damage the player takes. [code]source[/code]
## is the [Object] that inflicted the damage.
## [br][br]Can also return [code]void[/code] to never change the amount of damage.
@warning_ignore("unused_parameter")
func damage(amount: int, source: Object) -> int:
	return amount


## Called when the player gains or loses lives. [code]amount[/code] is the currently
## used value. Return this value to not change the amount of lives are lost or gained.
## [code]source[/code] is the [Object] that caused the life loss or gain.
## [br][br]Can also return [code]void[/code] to never change the amount of damage.
@warning_ignore("unused_parameter")
func change_life(amount: int, source: Object) -> int:
	return amount


## Called when the player dies. [code]source[/code] is the [Object] that caused
## the fatal life loss.
## [br][br]Call [method Stats.revive] to revive the player without using revives.
@warning_ignore("unused_parameter")
func player_death(source: Object) -> void:
	pass


## Called when the player loses the quest, after [method player_death] is called and
## the player cannot be revived.
@warning_ignore("unused_parameter")
func player_lose(source: Object) -> void:
	pass


## Called when the player spends coins. [code]amount[/code] is the currently used value.
## Return [code]amount[/code] to not change the amount of coins spent. [code]dest[/code]
## is the [Object] where the coins are spent on.
@warning_ignore("unused_parameter")
func spend_coins(amount: int, dest: Object) -> int:
	return amount


## Called when the player gains an [Item].
@warning_ignore("unused_parameter")
func item_gain(item: Item) -> void:
	pass


## Called when adding an [Item] to the player's inventory. If the item was gained
## by this effect, [method item_gain] is called [b]after[/b] this effect is called.
## [br][br][b]Note:[/b] The [Item] might not be gained by this effect. Whenever
## the [Statbar] is reloaded, this effect is also called.
@warning_ignore("unused_parameter")
func inventory_add_item(item: Item) -> void:
	pass


## Called when the player loses an [Item].
@warning_ignore("unused_parameter")
func item_lose(item: Item) -> void:
	pass


## Called whenever the player gains score. [code]score[/code] is the new value.
## Return this value to not influence the score.
## [br][br]Return [code]void[/code] to never influence the score.
func change_score(score: int) -> int:
	return score


## Called whenever [member Stats.cells_opened_since_mistake] changes.
## [code]cells_opened_since_mistake[/code] is the new value. Return this value to
## not influence the stat.
## [br][br]Return [code]void[/code] to never influence the stat.
func change_cells_opened_since_mistake(cells_opened_since_mistake: int) -> int:
	return cells_opened_since_mistake


## Called when the player's morality changes. [code]morality[/code] is the new value.
## Return this value to not influence the player's morality.
## [br][br]Return [code]void[/code] to never influence the player's morality.
func change_morality(morality: int) -> int:
	return morality


## Called whenever [member Stats.chests_opened] changes, i.e. whenever the player
## opens a chest. [code]chests_opened[/code] is the new value. Return this value
## to not influence the stat.
## [br][br][b]Note:[/b] Do not use this effect to react to opening a chest.
## Instead, use [method chest_opened].
func change_chests_opened(chests_opened: int) -> int:
	return chests_opened


## Called whenever the number of monsters the player has killed changes, i.e.
## whenever the player kills one or more monsters. [code]monsters_killed[/code]
## is the new value. Return this value to not influence the stat.
## [br][br][b]Note:[/b] Do not use this effect to react to killing a monster.
## Instead, use [method object_killed] and check for the object to be a [CellMonster].
func change_monsters_killed(monsters_killed: int) -> int:
	return monsters_killed


## Called whenever the player's pathfinding is changed. [code]pathfinding[/code]
## is the new value. Return this value to not influence the player's pathfinding.
## [br][br]Return [code]void[/code] to never influence the player's pathfinding.
func change_pathfinding(pathfinding: int) -> int:
	return pathfinding


## Called when obtaining any [Icon]. Can be used to override the icon's atlas.
## [br][br]Should be used together with [method parse_icon_rect]. This method will
## specify which texture to use as the atlas, [method parse_icon_rect] will
## specify which region in the texture to use for the icon.
@warning_ignore("unused_parameter")
func parse_icon_atlas(atlas: Texture2D, name: String) -> Texture2D:
	return atlas


## Called when obtaining any [Icon]. Can be used to override the icon's texture region.
## [br][br]Should be used together with [method parse_icon_atlas]. [method parse_icon_atlas]
## will specify which texture to use as the atlas, this method will
## specify which region in the texture to use for the icon.
@warning_ignore("unused_parameter")
func parse_icon_rect(rect: Rect2i, name: String) -> Rect2i:
	return rect
