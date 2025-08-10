@tool
extends Node
class_name QuestStats

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

var _effects := EffectSignals.new() : get = get_effects
var _mutable_effects := EffectSignals.new() : get = get_mutable_effects
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


func get_effects() -> EffectSignals:
	return _effects


func get_mutable_effects() -> EffectSignals:
	return _mutable_effects


## Restores [code]life[/code] lives, without exceeding the max lives.
@warning_ignore("shadowed_variable")
func life_restore(life: int, source: Object) -> int:
	if life <= 0:
		return 0
	
	life = EffectManager.propagate(get_mutable_effects().life_restore, [life, source], 0)
	EffectManager.propagate(get_effects().life_restore, [life, source])
	self.life = mini(self.life + life, max_life)
	return life


## Loses [code]life[/code] lives.
@warning_ignore("shadowed_variable")
func life_lose(life: int, source: Object) -> int:
	if life <= 0:
		return 0
	
	life = EffectManager.propagate(get_mutable_effects().life_lose, [life, source], 0)
	EffectManager.propagate(get_effects().life_lose, [life, source])
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
	EffectManager.propagate(get_mutable_effects().death, [source])
	EffectManager.propagate(get_effects().death, [source])
	if not _dying:
		life = max_life
		return
	
	_dying = false
	
	if revives > 0:
		revives -= 1
		life = max_life
		Toasts.add_toast("You now have %d revives..." % revives, IconManager.get_icon_data("icons/revive").create_texture())
		return
	
	lose()


## Causes the player to immediately lose the quest. If the player has any revives,
## they will not be used to revive the player. See also [method die].
func lose() -> void:
	EffectManager.propagate(get_effects().lose)
	
	# TODO


func revive() -> void:
	if _dying:
		_dying = false
		EffectManager.get_priority_tree().interrupt()
		
		EffectManager.propagate(get_effects().revive)


@warning_ignore("shadowed_variable")
func spend_coins(coins: int, destination: Object) -> int:
	if coins <= 0:
		return 0
	
	coins = EffectManager.propagate(get_mutable_effects().spend_coins, [coins, destination], 0)
	EffectManager.propagate(get_effects().spend_coins, [coins, destination])
	if coins <= 0:
		return 0
	
	lose_coins(coins, destination)
	return coins


@warning_ignore("shadowed_variable")
func lose_coins(coins: int, source: Object) -> int:
	if coins < 0:
		return 0
	
	coins = EffectManager.propagate(get_mutable_effects().lose_coins, [coins, source], 0)
	EffectManager.propagate(get_effects().lose_coins, [coins, source])
	coins = mini(coins, self.coins)
	self.coins -= coins
	return coins


@warning_ignore("shadowed_variable")
func gain_coins(coins: int, source: Object) -> int:
	if coins <= 0:
		return 0
	
	coins = EffectManager.propagate(get_mutable_effects().gain_coins, [coins, source], 0)
	EffectManager.propagate(get_effects().gain_coins, [coins, source])
	if coins <= 0:
		return 0
	
	self.coins += coins
	return coins


func damage(amount: int, source: Object) -> int:
	if get_quest().has_current_stage() and get_quest().get_current_stage().has_scene():
		get_quest().get_current_stage().get_scene().get_background().flash_red()
		get_quest().get_current_stage().get_board().get_camera().shake()
	
	amount = EffectManager.propagate(get_mutable_effects().damage, [amount, source], 0)
	EffectManager.propagate(get_effects().damage, [amount, source])
	
	if amount <= 0:
		return 0
	
	life_lose(amount, source)
	
	return maxi(0, amount)


func gain_souls(souls: int, source: Object) -> int:
	if souls <= 0:
		return 0
	
	souls = EffectManager.propagate(get_mutable_effects().gain_souls, [souls, source], 0)
	EffectManager.propagate(get_effects().gain_souls, [souls, source])
	
	if souls <= 0:
		return 0
	
	if life == max_life:
		max_life += souls
		life = max_life
	else:
		max_life += souls
		life_restore(souls, source)
	
	return souls


class EffectSignals:
	signal gain_souls(souls: int, source: Object)
	signal life_restore(life: int, source: Object)
	signal life_lose(life: int, source: Object)
	signal damage(amount: int, source: Object)
	signal death(source: Object)
	signal lose(source: Object)
	signal revive(source: Object)
	signal spend_coins(coins: int, destination: Object)
	signal lose_coins(coins: int, destination: Object)
	signal gain_coins(coins: int, source: Object)
