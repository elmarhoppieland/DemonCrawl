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
	
	if Stage.has_current():
		Stage.get_current().get_scene().get_background().flash_red()
	
	if self.life < 0:
		die()


## Causes the player to immediately die. If the player has any revives, one will
## be used to revive the player at maximum life. Otherwise, the player loses the quest.
## See also [method lose].
func die() -> void:
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


@warning_ignore("shadowed_variable")
func spend_coins(coins: int, destination: Object) -> void:
	self.coins -= Effects.spend_coins(coins, destination)


func damage(amount: int, source: Object) -> void:
	amount = Effects.damage(amount, source)
	if amount > 0:
		life_lose(amount, source)
	if Stage.has_current() and Stage.get_current().has_scene():
		Stage.get_current().get_board().get_camera().shake()
