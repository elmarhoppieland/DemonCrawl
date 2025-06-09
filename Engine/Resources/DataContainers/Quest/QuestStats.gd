extends Resource
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
# ==============================================================================

## Restores [code]life[/code] lives, without exceeding the max lives.
@warning_ignore("shadowed_variable")
func life_restore(life: int, source: Object) -> void:
	if life < 0:
		return
	
	self.life = mini(self.life + Effects.restore_life(life, source), max_life)


## Loses [code]life[/code] lives.
@warning_ignore("shadowed_variable")
func life_lose(life: int, source: Object) -> void:
	if life < 0:
		return
	
	self.life -= Effects.lose_life(life, source)
	
	if StageInstance.has_current():
		StageInstance.get_current().get_scene().get_background().flash_red()
	
	if self.life <= 0:
		die(source)


## Causes the player to immediately die. If the player has any revives, one will
## be used to revive the player at maximum life. Otherwise, the player loses the quest.
## See also [method lose].
func die(source: Object) -> void:
	_dying = true
	Effects.death(source)
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
	pass # TODO


func revive() -> void:
	if _dying:
		_dying = false
		EffectManager.get_priority_tree().interrupt()


@warning_ignore("shadowed_variable")
func spend_coins(coins: int, destination: Object) -> void:
	lose_coins(Effects.spend_coins(coins, destination), destination)


@warning_ignore("shadowed_variable")
func lose_coins(coins: int, destination: Object) -> void:
	self.coins -= mini(Effects.lose_coins(coins, destination), self.coins)


func damage(amount: int, source: Object) -> void:
	amount = Effects.damage(amount, source)
	if amount > 0:
		life_lose(amount, source)
	if StageInstance.has_current() and StageInstance.get_current().has_scene():
		StageInstance.get_current().get_board().get_camera().shake()


func gain_souls(souls: int, source: Object) -> void:
	if life == max_life:
		max_life += souls
		life = max_life
	else:
		max_life += souls
		life_restore(souls, source)
