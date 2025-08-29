extends Resource
class_name NomadOffer

# ==============================================================================
var _nomad: Nomad
# ==============================================================================

func _init(nomad: Nomad = null) -> void:
	_nomad = nomad


## Virtual method. Called (once) when this offer's object is first spawned into the [Stage].
## Is not called when reloading the [Stage].
func _spawn() -> void:
	pass


## Notifies the offer that its object has just been spawned.
func notify_spawned() -> void:
	_spawn()


## Virtual method to override the return value of [method get_description].
func _get_description() -> String:
	var values := {}
	for prop in get_property_list():
		if not prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		values[prop.name] = tr(str(get(prop.name)))
	
	return tr("STRANGER_NOMAD_" + _get_script_name().to_snake_case().to_upper()).format(values)


## Returns the Nomad's description.
func get_description() -> String:
	return _get_description()


## Virtual method. Override to specify whether the player can afford this offer.
## This is not called when the player activates the [Nomad] for free.
func _can_afford() -> bool:
	return true


## Returns whether the player can afford this offer. This usually means that the player has enough coins.
func can_afford() -> bool:
	return _can_afford()


## Virtual method. Override to specify whether the player can perform this offer
## (e.g. whether the player has the item that the [Nomad] is asking for). This is
## always called, even when the offer is made for free.
func _can_perform() -> bool:
	return true


## Returns whether the player can perform this offer. The player may not be able
## to afford it, see [method can_afford].
func can_perform() -> bool:
	return _can_perform()


## Virtual method. Called when the player activates this [Nomad], before calling [method _perform].
func _pay() -> void:
	pass


## Pays for this offer. This usually means the player spends coins equal to its cost.
## Should only be called if the player can afford this offer, see [method can_afford].
func pay() -> void:
	_pay()


## Virtual method. Called when the player interacts with the [Nomad], after checking
## whether this offer can be performed. See also [method _can_perform].
func _perform() -> void:
	pass


## Performs this offer. Should only be called if the offer can be performed. See also [method can_perform].
func perform() -> void:
	_perform()


## Virtual method. Override to change this offer's message (shown as a Toast) when
## the player attempts to perform this offer when they cannot. See also [method _can_perform].
func _get_fail_message() -> String:
	return tr("STRANGER_NOMAD_FAIL_" + _get_script_name().to_snake_case().to_upper())


## Returns this offer's message to be displayed when the player attempts to perform
## this offer when they cannot. See also [method can_perform].
func get_fail_message() -> String:
	return _get_fail_message()


## Virtual method to override the return value of [method is_enabled]. Returns [code]true[/code]
## by default. When this returns [code]false[/code], this offer will not be applied
## to a Nomad.
static func _is_enabled() -> bool:
	return true


## Returns whether the provided [NomadOffer] is enabled or not. A disabled [NomadOffer] cannot
## be applied to a Nomad.
static func is_enabled(script: Script) -> bool:
	return script._is_enabled()


func _get_script_name() -> String:
	return UserClassDB.script_get_class(get_script()).trim_prefix("Nomad").trim_suffix("Offer")
