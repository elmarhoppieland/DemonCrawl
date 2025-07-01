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


## Virtual method. Called when this [Aura] is applied to a [code]cell[/code].
@warning_ignore("unused_parameter")
func _apply(cell: CellData) -> void:
	pass


## Notifies this [Aura] that it is applied to the given [code]cell[/code].
func notify_applied(cell: CellData) -> void:
	_apply(cell)
	
	initialize_on_cell(cell)


## Virtual method. Called when this [Aura] should initialize on the given [code]cell[/code].
## [br][br][b]Note:[/b] A single [Aura] may be shared across multiple [Cell]s.
@warning_ignore("unused_parameter")
func _cell_init(cell: CellData) -> void:
	pass


## Initializes this [Aura] on the given [code]cell[/code].
func initialize_on_cell(cell: CellData) -> void:
	_cell_init(cell)
	_cell_load(cell)
	
	var stage := cell.get_stage_instance()
	stage.loaded.connect(_cell_load.bind(cell))
	stage.unloaded.connect(_cell_unload.bind(cell))


## Virtual method. Called when this [Aura] has been removed from the given [code]cell[/code].
@warning_ignore("unused_parameter")
func _remove(cell: CellData) -> void:
	pass


## Notifies this [Aura] that is has been removed from the given [code]cell[/code].
func notify_removed(cell: CellData) -> void:
	_remove(cell)
	
	var stage := cell.get_stage_instance()
	stage.loaded.disconnect(_cell_load.bind(cell))
	stage.unloaded.disconnect(_cell_unload.bind(cell))


## Virtual method. Called when this [Aura] is loaded on the given [code]cell[/code].
@warning_ignore("unused_parameter")
func _cell_load(cell: CellData) -> void:
	pass


## Virtual method. Called when this [Aura] is unloaded on the given [code]cell[/code].
@warning_ignore("unused_parameter")
func _cell_unload(cell: CellData) -> void:
	pass


## Virtual method. Called whenever the given [code]cell[/code] is second-interacted with.
@warning_ignore("unused_parameter")
func _second_interacted(cell: CellData) -> void:
	pass


func negative_effect(effect: Callable) -> void:
	Immunity.try_call(func() -> void: effect.call(), "negative_effect")


func _export_packed() -> Array:
	return []
