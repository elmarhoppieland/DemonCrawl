@tool
extends MarginContainer
class_name Stats

# ==============================================================================
#static var _instance: Stats :
	#get:
		#if not is_instance_valid(_instance):
			#_instance = null
		#return _instance

#static var max_life: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_max_life(value)
		#max_life = value
		#if _instance:
			#_instance._update_life_label()
#static var life: int = Eternal.create(0) :
	#set(value):
		#life = value
		#
		#if _instance:
			#_instance._update_life_label()
#static var revives: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_revives(value)
		#revives = value
		#if _instance:
			#_instance._update_revives()
#static var defense: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_defense(value)
		#defense = value
		#if _instance:
			#_instance._update_defense_label()
#static var coins: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_coins(value)
		#var increased := value > coins
		#coins = value
		#
		#if not _instance:
			#return
		#
		#_instance._update_coins_label()
		#if increased:
			#if not _instance._animation_player:
				#await _instance.ready
			#_instance._animation_player.play("coin_gain")
#
#static var untouchable: bool = Eternal.create(true)
#
#static var score: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_score(value)
		#score = value
#static var cells_opened_since_mistake: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_cells_opened_since_mistake(value)
		#cells_opened_since_mistake = value
#static var morality: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_morality(value)
		#morality = value
#static var chain: ChainData = Eternal.create(null) :
	#set(value):
		#value = Effects.change_chain(value)
		#chain = value
#static var chests_opened: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_chests_opened(value)
		#chests_opened = value
#static var monsters_killed: int = Eternal.create(0) :
	#set(value):
		#value = Effects.change_monsters_killed(value)
		#monsters_killed = value
# ==============================================================================
@onready var _life_label: Label = %LifeLabel
@onready var _defense_label: Label = %DefenseLabel
@onready var _coins_label: Label = %CoinsLabel
#@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

## Deals [code]amount[/code] damage to the player. Before causing life loss,
## propagates [code]damage(amount, source)[/code] through the [EffectManager].
#static func damage(amount: int, source: Object = null) -> void:
	#Stage.get_current().get_board().get_camera().shake()
	#Stage.get_current().get_scene().get_background().flash_red()
	#
	#amount = Effects.damage(amount, source)
	#if amount <= 0:
		#return
	#
	#amount = maxi(1, amount - defense)
	#
	#change_life(-amount, source)
	#untouchable = false


## Changes the current [member life] by the given amount. Before changing the value,
## propagates [code]change_life(amount, source)[/code] through the [EffectManager].
## If the call changes the sign of [code]amount[/code], does not change [member life].
#static func change_life(amount: int, source: Object = null) -> void:
	#var original_sign := signi(amount)
	#amount = Effects.change_life(amount, source)
	#if signi(amount) != original_sign:
		#return
	#
	#life = mini(life + amount, max_life)
	#
	#if life > 0:
		#return
	#
	#Effects.death(source)
	#if life > 0:
		#return
	#
	#if revives > 0:
		#revives -= 1
		#revive()
		#return
	#
	#Effects.player_lose(source)


#static func set_life(value: int, source: Object = null) -> void:
	#change_life(value - life, source)


#static func spend_coins(amount: int, dest: Object = null) -> void:
	#amount = Effects.spend_coins(amount, dest)
	#coins -= amount


#static func get_coin_position() -> Vector2:
	#return _instance._coins_label.global_position


# TODO: should revive the player when called in the death() propagation without using any revives
#static func revive(new_life: int = max_life) -> void:
	#life = new_life


#static func get_stats_tooltip_text() -> String:
	#var parts := PackedStringArray([
		#"%s: %d %s" % [TranslationServer.tr("SCORE"), score, TranslationServer.tr("POINTS_ABBR")],
		#"%s: %d" % [TranslationServer.tr("CELLS_OPENED_SINCE_MISTAKE"), cells_opened_since_mistake],
		#"%s: %d" % [TranslationServer.tr("MORALITY"), morality]
	#])
	#
	#if chain and chain.length > 1:
		#parts.append_array([
			#"%s: %d %s" % [TranslationServer.tr("CHAIN_LENGTH"), chain.length, TranslationServer.tr("TURNS")],
			#"%s: %d" % [TranslationServer.tr("CHAIN_VALUE"), chain.value],
			#"%s: %d" % [TranslationServer.tr("CHAIN_SUM"), chain.get_sum()]
		#])
	#
	#parts.append_array([
		#"%s: %d" % [TranslationServer.tr("CHESTS_OPENED"), chests_opened],
		#"%s: %d" % [TranslationServer.tr("MONSTERS_KILLED"), monsters_killed]
	#])
	#
	#return "• " + "\n• ".join(parts)


#func _init() -> void:
	#_instance = self


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_update_life_label()
	_update_defense_label()
	_update_coins_label()
	
	Quest.get_current().get_instance().changed.connect(func() -> void:
		_update_life_label()
		_update_defense_label()
		_update_coins_label()
	)


func _update_life_label() -> void:
	if not is_node_ready():
		await ready
	
	_life_label.text = "%d/%d" % [Quest.get_current().get_instance().life, Quest.get_current().get_instance().max_life]


func _update_revives() -> void:
	if not is_node_ready():
		await ready
	
	pass # should show/hide revives


func _update_defense_label() -> void:
	if not is_node_ready():
		await ready
	
	_defense_label.text = str(Quest.get_current().get_instance().defense)


func _update_coins_label() -> void:
	if not is_node_ready():
		await ready
	
	_coins_label.text = str(Quest.get_current().get_instance().coins)


#class ChainData:
	#var length := 0
	#var value := 0
	#
	#func get_sum() -> int:
		#return length * value
