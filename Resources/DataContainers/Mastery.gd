extends Resource
class_name Mastery

# ==============================================================================
@export var level := 0
# ==============================================================================

func _init() -> void:
	level = TokenShop.get_purchased_level(_get_identifier())

#region decription & visualization

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
