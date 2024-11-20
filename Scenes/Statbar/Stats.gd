extends MarginContainer
class_name Stats

# ==============================================================================
static var _instance: Stats :
	get:
		if not is_instance_valid(_instance):
			_instance = null
		return _instance

# SavesManager.get_value("max_life", Stats, 0)
static var max_life: int = Eternal.create(0) :
	set(value):
		value = Effects.change_max_life(value)
		max_life = value
		if _instance:
			_instance._update_life_label()
# SavesManager.get_value("life", Stats, 0)
static var life: int = Eternal.create(0) :
	set(value):
		life = value
		
		if _instance:
			_instance._update_life_label()
# SavesManager.get_value("revives", Stats, 0)
static var revives: int = Eternal.create(0) :
	set(value):
		value = Effects.change_revives(value)
		revives = value
		if _instance:
			_instance._update_revives()
# SavesManager.get_value("defense", Stats, 0)
static var defense: int = Eternal.create(0) :
	set(value):
		value = Effects.change_defense(value)
		defense = value
		if _instance:
			_instance._update_defense_label()
# SavesManager.get_value("coins", Stats, 0)
static var coins: int = Eternal.create(0) :
	set(value):
		value = Effects.change_coins(value)
		var increased := value > coins
		coins = value
		
		if not _instance:
			return
		
		_instance._update_coins_label()
		if increased:
			if not _instance._animation_player:
				await _instance.ready
			_instance._animation_player.play("coin_gain")

# SavesManager.get_value("untouchable", Stats, true)
static var untouchable: bool = Eternal.create(true)
# ==============================================================================
@onready var _life_label: Label = %LifeLabel
@onready var _defense_label: Label = %DefenseLabel
@onready var _coins_label: Label = %CoinsLabel
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

## Deals [code]amount[/code] damage to the player. Before causing life loss,
## propagates [code]damage(amount, source)[/code] through the [EffectManager].
static func damage(amount: int, source: Object = null) -> void:
	StageCamera.shake()
	BoardBackground.flash_red()
	
	amount = Effects.damage(amount, source)
	if amount <= 0:
		return
	
	amount = maxi(1, amount - defense)
	
	change_life(-amount, source)
	untouchable = false


## Changes the current [member life] by the given amount. Before changing the value,
## propagates [code]change_life(amount, source)[/code] through the [EffectManager].
## If the call changes the sign of [code]amount[/code], does not change [member life].
static func change_life(amount: int, source: Object = null) -> void:
	var original_sign := signi(amount)
	amount = Effects.change_life(amount, source)
	if signi(amount) != original_sign:
		return
	
	life = mini(life + amount, max_life)
	
	if life > 0:
		return
	
	Effects.death(source)
	if life > 0:
		return
	
	if revives > 0:
		revives -= 1
		revive()
		return
	
	Effects.player_lose(source)


static func set_life(value: int, source: Object = null) -> void:
	change_life(value - life, source)


static func spend_coins(amount: int, dest: Object = null) -> void:
	amount = Effects.spend_coins(amount, dest)
	coins -= amount


static func get_coin_position() -> Vector2:
	return _instance._coins_label.global_position


# TODO: should revive the player when called in the death() propagation without using any revives
static func revive(new_life: int = max_life) -> void:
	life = new_life


func _init() -> void:
	_instance = self


func _ready() -> void:
	_update_life_label()
	_update_defense_label()
	_update_coins_label()


func _update_life_label() -> void:
	if not is_node_ready():
		await ready
	
	_life_label.text = "%d/%d" % [life, max_life]


func _update_revives() -> void:
	if not is_node_ready():
		await ready
	
	pass # should show/hide revives


func _update_defense_label() -> void:
	if not is_node_ready():
		await ready
	
	_defense_label.text = str(defense)


func _update_coins_label() -> void:
	if not is_node_ready():
		await ready
	
	_coins_label.text = str(coins)
