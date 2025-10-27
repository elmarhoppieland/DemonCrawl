@tool
extends Node
class_name QuestStats

# ==============================================================================
const REVIVE_TEXTURE: Texture2D = null # TODO
# ==============================================================================
@export var max_life := 0 :
	set(value):
		max_life = value
		emit_changed()
@export var life := 0 :
	set(value):
		life = value
		emit_changed()
@export var revives := 0 :
	set(value):
		revives = value
		emit_changed()
@export var defense := 0 :
	set(value):
		defense = value
		emit_changed()
@export var coins := 0 :
	set(value):
		coins = value
		emit_changed()
# ==============================================================================
var _dying := false
# ==============================================================================
signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func _init() -> void:
	name = "Stats"


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_effects() -> StatsEffects:
	return get_quest().get_event_bus(StatsEffects)


## Restores [param life] lives, without exceeding the max lives.
@warning_ignore("shadowed_variable")
func life_restore(life: int, source: Object) -> int:
	if life <= 0:
		return 0
	
	life = EffectManager.propagate_mutable(get_effects().restore_life, 0, life, source)
	EffectManager.propagate(get_effects().life_restored, life, source)
	self.life = mini(self.life + life, max_life)
	return life


## Loses [param life] lives.
@warning_ignore("shadowed_variable")
func life_lose(life: int, source: Object) -> int:
	if life <= 0:
		return 0
	
	life = EffectManager.propagate_mutable(get_effects().lose_life, 0, life, source)
	EffectManager.propagate(get_effects().life_lost, life, source)
	if life <= 0:
		return 0
	
	self.life -= life
	
	if self.life <= 0:
		die(source)
	
	return life


## Causes the player to immediately die. If the player has any revives, one will
## be used to revive the player at maximum life. Otherwise, the player loses the quest.
## See also [method lose].
func die(source: Object) -> void:
	_dying = true
	EffectManager.propagate(get_effects().die, source)
	EffectManager.propagate(get_effects().died, source)
	if not _dying:
		life = max_life
		return
	
	_dying = false
	
	if revives > 0:
		revives -= 1
		life = max_life
		Toasts.add_toast("You now have %d revives..." % revives, REVIVE_TEXTURE)
		return
	
	lose()


## Causes the player to immediately lose the quest. If the player has any revives,
## they will not be used to revive the player. See also [method die].
func lose() -> void:
	EffectManager.propagate(get_effects().lose)
	EffectManager.propagate(get_effects().lost)
	
	# TODO


func revive() -> void:
	if _dying:
		_dying = false
		EffectManager.get_priority_tree().interrupt()
		
		EffectManager.propagate(get_effects().revive)
		EffectManager.propagate(get_effects().revived)


@warning_ignore("shadowed_variable")
func spend_coins(coins: int, destination: Object) -> int:
	if coins <= 0:
		return 0
	
	coins = EffectManager.propagate_mutable(get_effects().spend_coins, 0, coins, destination)
	EffectManager.propagate(get_effects().coins_spent, coins, destination)
	if coins <= 0:
		return 0
	
	lose_coins(coins, destination)
	return coins


@warning_ignore("shadowed_variable")
func lose_coins(coins: int, source: Object) -> int:
	if coins < 0:
		return 0
	
	coins = EffectManager.propagate_mutable(get_effects().lose_coins, 0, coins, source)
	EffectManager.propagate(get_effects().coins_lost, coins, source)
	coins = mini(coins, self.coins)
	self.coins -= coins
	return coins


@warning_ignore("shadowed_variable")
func gain_coins(coins: int, source: Object) -> int:
	if coins <= 0:
		return 0
	
	coins = EffectManager.propagate_mutable(get_effects().gain_coins, 0, coins, source)
	EffectManager.propagate(get_effects().coins_gained, coins, source)
	if coins <= 0:
		return 0
	
	self.coins += coins
	return coins


func damage(amount: int, source: Object) -> int:
	if get_quest().has_current_stage() and get_quest().get_current_stage().has_scene():
		get_quest().get_current_stage().get_scene().get_background().flash_red()
		get_quest().get_current_stage().get_board().get_camera().shake()
	
	amount = EffectManager.propagate_mutable(get_effects().take_damage, 0, amount, source)
	EffectManager.propagate(get_effects().damage_taken, amount, source)
	
	if amount <= 0:
		return 0
	
	life_lose(amount, source)
	
	return maxi(0, amount)


func gain_souls(souls: int, source: Object) -> int:
	if souls <= 0:
		return 0
	
	souls = EffectManager.propagate_mutable(get_effects().gain_souls, 0, souls, source)
	EffectManager.propagate(get_effects().souls_gained, souls, source)
	
	if souls <= 0:
		return 0
	
	if life == max_life:
		max_life += souls
		life = max_life
	else:
		max_life += souls
		life_restore(souls, source)
	
	return souls


class StatsEffects extends EventBus:
	signal gain_souls(souls: int, source: Object)
	signal souls_gained(souls: int, source: Object)
	
	signal restore_life(life: int, source: Object)
	signal life_restored(life: int, source: Object)
	
	signal lose_life(life: int, source: Object)
	signal life_lost(life: int, source: Object)
	
	signal take_damage(amount: int, source: Object)
	signal damage_taken(amount: int, source: Object)
	
	signal die(source: Object)
	signal died(source: Object)
	
	signal lose(source: Object)
	signal lost(source: Object)
	
	signal revive(source: Object)
	signal revived(source: Object)
	
	signal spend_coins(coins: int, destination: Object)
	signal coins_spent(coins: int, destination: Object)
	
	signal lose_coins(coins: int, destination: Object)
	signal coins_lost(coins: int, destination: Object)
	
	signal gain_coins(coins: int, source: Object)
	signal coins_gained(coins: int, source: Object)
