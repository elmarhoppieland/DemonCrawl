@tool
extends Resource
class_name Aura

# ==============================================================================

## Returns this [Aura]'s modulation.
func get_modulate() -> Color:
	return _get_modulate()


## Virtual method. Should return this [Aura]'s modulation [Color].
func _get_modulate() -> Color:
	return Color.WHITE


## Returns whether this [Aura] is elemental.
func is_elemental() -> bool:
	return _is_elemental()


## Virtual method. Should return [code]true[/code] if this [Aura] is elemental.
func _is_elemental() -> bool:
	return false


## Notifies this [Aura] that the given [code]cell[/code] has been interacted with.
func notify_interacted(cell: CellData) -> void:
	_interact(cell)


## Virtual method. Called whenever the given [code]cell[/code] is interacted with.
@warning_ignore("unused_parameter")
func _interact(cell: CellData) -> void:
	pass


## Notifies this [Aura] that the given [code]cell[/code] has been second-interacted with.
func notify_second_interacted(cell: CellData) -> void:
	_second_interacted(cell)


## Virtual method. Called whenever the given [code]cell[/code] is second-interacted with.
@warning_ignore("unused_parameter")
func _second_interacted(cell: CellData) -> void:
	pass


func negative_effect(effect: Callable) -> void:
	Immunity.try_call(func() -> void: effect.call(), "negative_effect")


func _export_packed() -> Array:
	return []
