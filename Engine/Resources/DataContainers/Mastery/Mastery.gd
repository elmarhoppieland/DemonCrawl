@tool
extends Resource
class_name Mastery

# ==============================================================================
@export var level := 0 :
	set(value):
		level = mini(value, get_max_level())
		emit_changed()
@export var charges := -1 :
	set(value):
		charges = value
		emit_changed()
# ==============================================================================
var quest: Quest = null : set = set_quest, get = get_quest
# ==============================================================================

#region virtuals

## Virtual method. Called (once) when the [Quest] starts.
func _quest_start() -> void:
	pass


## Virtual method. Called (once) when the player wins the [Quest].
func _quest_win() -> void:
	pass


## Virtual method. Called (once) when the player loses or abandons the [Quest].
func _quest_lose() -> void:
	pass


## Virtual method. Called every time the player loads the [Quest] (usually after entering
## the [StageSelect] or [StageScene] from the [MainMenu] or [QuestSelect]). Also called
## when the player starts the [Quest].
## [br][br]Can be used to connect to effect [Signal]s.
func _quest_load() -> void:
	pass


## Virtual method. Called every time the player exits the [Quest] (usually before entering
## the [MainMenu]). Also called when the player wins, loses or abandons the [Quest].
## [br][br]Can be used to disconnect from effect [Signal]s.
func _quest_unload() -> void:
	pass

#endregion

#region decription & visualization

## Returns this [Mastery]'s name.
func get_display_name() -> String:
	return _get_name()


## Virtual method to override this [Mastery]'s name. If not overridden, uses the identifier
## to generate a translatable string:
## [br][code]MASTERY_{id}[/code]
func _get_name() -> String:
	var name := tr("MASTERY_" + _get_identifier())
	if level > 0:
		name += " " + RomanNumeral.convert_to_roman(level)
	return name


## Returns this [Mastery]'s full description. Each level is one element in the returned array.
func get_description() -> PackedStringArray:
	var description := PackedStringArray()
	
	for i in range(1, level + 1):
		description.append(_get_description(i))
	
	return description


## Virtual method to override the given [code]level[/code] of this [Mastery]'s description.
## [br][br]If this method is not overridden, uses this [Mastery]'s identifier (see
## [method _get_identifier]) to generate a translatable string:
## [br][code]MASTERY_{id}_DESCRIPTION_{level}[/code].
@warning_ignore("shadowed_variable")
func _get_description(level: int) -> String:
	var description := tr("MASTERY_%s_DESCRIPTION_%d" % [_get_identifier(), level])
	
	if level != 3:
		return description
	
	var max_charges := get_max_charges()
	if max_charges <= 0:
		return description
	
	var charges := get_charges()
	if charges >= 0:
		return "[%d/%d] %s" % [
			charges,
			max_charges,
			description
		]
	
	return "[%d %s] %s" % [
		max_charges,
		Translator.translate("CHARGES", max_charges),
		description
	]


func get_description_text() -> String:
	var description := get_description()
	if description.is_empty():
		return ""
	
	return "• " + "\n• ".join(description)


## Creates and returns a new icon for this [Mastery].
func create_icon() -> Texture2D:
	return IconManager.get_icon_data("mastery%d/%s" % [level if level > 0 else 1, UserClassDB.script_get_class(get_script())]).create_texture()


## Virtual method to override this [Mastery]'s identifier. If not overridden, converts
## the [Mastery]'s class name into an identifier.
func _get_identifier() -> String:
	return UserClassDB.script_get_class(get_script()).to_snake_case().to_upper()


## Returns the [Token] cost for this [Mastery] at the given [code]level[/code].
func get_cost() -> int:
	return _get_cost()


## Virtual method to override the [Token] cost for this [Mastery] at the given [code]level[/code].
## If not overridden, returns [code]level * 10[/code].
func _get_cost() -> int:
	return level * 10


## Returns this [Mastery]'s unlock [Condition]s. All of them must be met (see [method Condition.is_met])
## before being able to purchase this [Mastery].
func get_conditions() -> Array[Condition]:
	return _get_conditions()


## Virtual method to override this [Mastery]'s unlock [Condition]s. All of them
## must be met (see [method Condition.is_met]) before being able to purchase this [Mastery].
## [br][br]If not overridden, returns a [MasteryUnlockConditon] for this [Mastery].
@warning_ignore("shadowed_variable")
func _get_conditions() -> Array[Condition]:
	var condition := MasteryUnlockConditon.new()
	condition.mastery = self
	return [condition]


## Returns a [String] explaining how to unlock this [Mastery]'s level.
func get_condition_text() -> String:
	return _get_condition_text()


## Virtual method to explain how to unlock this [Mastery]'s level. If not overridden,
## returns a translatable [String]: [code]MASTERY_{id}_UNLOCK_{level}[/code].
func _get_condition_text() -> String:
	return tr("MASTERY_%s_UNLOCK_%d" % [_get_identifier(), level])


func get_max_charges() -> int:
	return _get_max_charges()


func _get_max_charges() -> int:
	return -1


func get_charges() -> int:
	return charges


func is_charged() -> bool:
	return charges >= 0 and get_charges() >= get_max_charges()


func gain_charge() -> void:
	if charges >= 0 and charges < get_max_charges():
		charges += 1


func get_max_level() -> int:
	return _get_max_level()


func _get_max_level() -> int:
	return 3

#endregion

#region utilities

func set_quest(value: Quest) -> void:
	if quest:
		quest.loaded.disconnect(_quest_load)
		quest.unloaded.disconnect(_quest_unload)
		quest.started.disconnect(_quest_start)
		quest.lost.disconnect(_quest_lose)
		quest.won.disconnect(_quest_win)
	
	quest = value
	
	if value:
		value.loaded.connect(_quest_load)
		value.unloaded.connect(_quest_unload)
		value.started.connect(_quest_start)
		value.lost.connect(_quest_lose)
		value.won.connect(_quest_win)


func get_quest() -> Quest:
	return quest


func get_inventory() -> QuestInventory:
	return get_quest().get_inventory()


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_attributes() -> QuestPlayerAttributes:
	return get_quest().get_attributes()


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_inventory().get_item_count():
		items.append(get_inventory().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_stats().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_stats().life_lose(life, source)

#endregion

## Activates this [Mastery]'s ability. This does [b]not[/b] reset its charges,
## or check the [Mastery]'s [member level].
func activate_ability() -> void:
	get_attributes().mastery_activations += 1
	
	_ability()


## If this [Mastery] is charged (see [method is_charged]), activates the ability
## (see [activate_ability]) and resets its charges to zero.
func use_ability() -> void:
	if is_charged() and can_use_ability():
		activate_ability()
		charges = 0


## Returns whether this [Mastery]'s ability can currently be used. Does [b]not[/b]
## check whether it is charged.
func can_use_ability() -> bool:
	return _can_use_ability()


## Vitual method. Should return [code]true[/code] if this [Mastery]'s ability can
## currently be used (regardless of whether it is charged), and [code]false[/code] if not.
func _can_use_ability() -> bool:
	return true


## Virtual method. Called when the [Mastery]'s ability is activated (see [method activate_ability]).
## Should perform its effects without checking the [Mastery]'s level. Also should not
## reset the ability's charges.
func _ability() -> void:
	pass


## Returns the description of this [Mastery]'s ability.
func get_ability_description() -> String:
	var override := _get_ability_description()
	return tr("MASTERY_%s_ABILITY" % _get_identifier()) if override.is_empty() else override


## Virtual method to override the return value of [method get_ability_description].
func _get_ability_description() -> String:
	return ""


## Virtual method. Called when exporting this [Mastery] and should return
## all properties that should be exported.
## [br][br]If this returns an empty [PackedStringArray], this [Mastery] will
## be packed (i.e. saved as [code]MasteryName(level, charges)[/code]).
func _get_export_properties() -> PackedStringArray:
	return []


func _validate_property(property: Dictionary) -> void:
	if property.name in _get_export_properties():
		property.usage |= PROPERTY_USAGE_STORAGE


func _export_packed_enabled() -> bool:
	return _get_export_properties().is_empty()


func _export_packed() -> Array:
	if charges >= 0:
		return [level, charges]
	return [level]


@warning_ignore("shadowed_variable")
static func _import_packed_static(script_name: String, level: int, charges: int = -1) -> Mastery:
	var mastery: Mastery = UserClassDB.instantiate(script_name)
	mastery.level = level
	mastery.charges = charges
	return mastery
