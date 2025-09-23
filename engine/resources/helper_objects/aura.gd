@tool
@abstract
extends Node
class_name Aura

# ==============================================================================

func _ready() -> void:
	if Eternity.get_processing_file() != null:
		return
	
	_spawn()


## Virtual method. Called when this [Aura] first spawns into a [CellData].
func _spawn() -> void:
	pass


func get_cell() -> CellData:
	return get_parent()


func get_stage() -> Stage:
	var base := get_parent()
	while base != null and base is not Stage:
		base = base.get_parent()
	return base


func get_stage_instance() -> StageInstance:
	var base := get_parent()
	while base != null and base is not StageInstance:
		base = base.get_parent()
	return base


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


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


## Notifies this [Aura] that the given [param cell] has been interacted with.
func notify_interacted(cell: CellData) -> void:
	_interact(cell)


## Virtual method. Called whenever the given [param cell] is interacted with.
@warning_ignore("unused_parameter")
func _interact(cell: CellData) -> void:
	pass


## Notifies this [Aura] that the given [param cell] has been second-interacted with.
func notify_second_interacted(cell: CellData) -> void:
	_second_interact(cell)


## Virtual method. Called whenever the given [param cell] is second-interacted with.
@warning_ignore("unused_parameter")
func _second_interact(cell: CellData) -> void:
	pass


func negative_effect(effect: Callable) -> void:
	get_stage_instance().get_immunity().try_call(func() -> void: effect.call(), "negative_effect")
