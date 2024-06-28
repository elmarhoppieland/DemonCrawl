extends MarginContainer
class_name Stats

# ==============================================================================
static var _instance: Stats :
	get:
		if not is_instance_valid(_instance):
			_instance = null
		return _instance

static var max_life: int = SavesManager.get_value("max_life", Stats, 0) :
	set(value):
		value = EffectManager.change_stat("max_life", value)
		max_life = value
		if _instance:
			_instance._update_life_label()
static var life: int = SavesManager.get_value("life", Stats, 0) :
	set(value):
		life = value
		
		if _instance:
			_instance._update_life_label()
static var revives: int = SavesManager.get_value("revives", Stats, 0) :
	set(value):
		value = EffectManager.change_stat("revives", value)
		revives = value
		if _instance:
			_instance._update_revives()
static var defense: int = SavesManager.get_value("defense", Stats, 0) :
	set(value):
		value = EffectManager.change_stat("defense", value)
		defense = value
		if _instance:
			_instance._update_defense_label()
static var coins: int = SavesManager.get_value("coins", Stats, 0) :
	set(value):
		value = EffectManager.change_stat("coins", value)
		var increased := value > coins
		coins = value
		
		if not _instance:
			return
		
		_instance._update_coins_label()
		if increased:
			if not _instance._animation_player:
				await _instance.ready
			_instance._animation_player.play("coin_gain")

static var untouchable: bool = SavesManager.get_value("untouchable", Stats, true)
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
	
	amount = EffectManager.propagate_posnum("damage", [source], amount)
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
	amount = EffectManager.propagate_value("change_life", [source], amount)
	if signi(amount) != original_sign:
		return
	
	life = mini(life + amount, max_life)
	
	if life > 0:
		return
	
	EffectManager.propagate_call("death", [source])
	if life > 0:
		return
	
	if revives > 0:
		revives -= 1
		revive()
		return
	
	EffectManager.propagate_call("lose", [source])


static func set_life(value: int, source: Object = null) -> void:
	change_life(value - life, source)


static func spend_coins(amount: int, dest: Object = null) -> void:
	amount = EffectManager.propagate_posnum("spend_coins", [dest], amount)
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
