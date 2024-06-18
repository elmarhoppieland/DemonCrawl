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
		value = EffectManager.change_stat("life", value)
		life = value
		if _instance:
			_instance._update_life_label()
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

static func damage(amount: int, source: Object = null) -> void:
	StageCamera.shake()
	BoardBackground.flash_red()
	
	amount = EffectManager.propagate_posnum("damage", [source], amount)
	if amount <= 0:
		return
	
	life -= maxi(1, amount - defense)
	untouchable = false


static func get_coin_position() -> Vector2:
	return _instance._coins_label.global_position


# TODO: should revive the player when called in the death() propagation without using any revives
static func revive() -> void:
	pass


func _init() -> void:
	_instance = self


func _ready() -> void:
	_update_life_label()
	_update_defense_label()
	_update_coins_label()


func _update_life_label() -> void:
	if not _life_label:
		await ready
	
	_life_label.text = "%d/%d" % [life, max_life]


func _update_defense_label() -> void:
	if not _defense_label:
		await ready
	
	_defense_label.text = str(defense)


func _update_coins_label() -> void:
	if not _coins_label:
		await ready
	
	_coins_label.text = str(coins)
