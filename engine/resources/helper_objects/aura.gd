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


func get_name_id() -> String:
	return _get_name_id()


@abstract func _get_name_id() -> String


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
@abstract func _get_modulate() -> Color


## Returns whether this [Aura] is elemental.
func is_elemental() -> bool:
	return _is_elemental()


## Virtual method. Should return [code]true[/code] if this [Aura] is elemental.
func _is_elemental() -> bool:
	return false


## Notifies this [Aura] that the given [param cell] has been interacted with.
func notify_interacted() -> void:
	_interact()


## Virtual method. Called whenever the given [param cell] is interacted with.
@warning_ignore("unused_parameter")
func _interact() -> void:
	pass


## Notifies this [Aura] that the given [param cell] has been second-interacted with.
func notify_second_interacted(cell: CellData) -> void:
	_second_interact(cell)


## Virtual method. Called whenever the given [param cell] is second-interacted with.
@warning_ignore("unused_parameter")
func _second_interact(cell: CellData) -> void:
	pass


func negative_effect(effect: Callable) -> Variant:
	return Immunity.try_call(effect, (get_stage_instance().get_event_bus(AuraEffects) as AuraEffects).can_apply_negative_effect, self, effect)

@warning_ignore_start("unused_signal")

class AuraEffects extends EventBus:
	signal can_apply_negative_effect(aura: Aura, effect: Callable, can_apply: bool)

@warning_ignore_restore("unused_signal")
