extends Resource
class_name Mastery

# ==============================================================================
@export var level := 0
# ==============================================================================

#region decription & visualization

## Returns this [Mastery]'s name.
func get_display_name() -> String:
	return _get_name()


## Virtual method to override this [Mastery]'s name. If not overridden, uses the identifier
## to generate a translatable string:
## [br][code]MASTERY_{id}[/code]
func _get_name() -> String:
	return tr("MASTERY_" + _get_identifier())


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
	return tr("MASTERY_%s_DESCRIPTION_%d" % [_get_identifier(), level])


## Creates and returns a new icon for this [Mastery].
func create_icon() -> Texture2D:
	return IconManager.get_icon_data("mastery%d/%s" % [level, UserClassDB.script_get_class(get_script())]).create_texture()


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
## [br][br]If not overridden, returns a [FlagCondition] for [code]mastery_unlock_{id}_{level}[/code].
@warning_ignore("shadowed_variable")
func _get_conditions() -> Array[Condition]:
	var condition := FlagCondition.new()
	condition.flag = "mastery_unlock_%s_%d" % [_get_identifier(), level]
	return [condition]


## Returns a [String] explaining how to unlock this [Mastery]'s level.
func get_condition_text() -> String:
	return _get_condition_text()


## Virtual method to explain how to unlock this [Mastery]'s level. If not overridden,
## returns a translatable [String]: [code]MASTERY_{id}_UNLOCK_{level}[/code].
func _get_condition_text() -> String:
	return tr("MASTERY_%s_UNLOCK_%d" % [_get_identifier(), level])

#endregion

#region utilities

func get_quest() -> Quest:
	return Quest.get_current()


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
## or check the [Mastery]'s level.
func activate_ability() -> void:
	_ability()


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
