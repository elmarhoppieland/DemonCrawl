@tool
extends Resource
class_name Aura

# ==============================================================================
static var _instances := {}
# ==============================================================================

## Creates an aura with the given [Script]. The [Script] must extend [Aura]
## (directly or indirectly).
static func create(script: Script) -> Aura:
	if script in _instances:
		return _instances[script]
	
	var value: Aura = script.new()
	_instances[script] = value
	return value


## Returns this [Aura]'s modulation.
func get_modulate() -> Color:
	return _get_modulate()


## Virtual method. Should return this [Aura]'s modulation [Color].
func _get_modulate() -> Color:
	return Color.WHITE


## Notifies this [Aura] that the given [code]cell[/code] has been interacted with.
func notify_interacted(cell: CellData) -> void:
	_interact(cell)


## Virtual method. Called whenever the given [code]cell[/code] is interacted with.
@warning_ignore("unused_parameter")
func _interact(cell: CellData) -> void:
	pass


func _export_packed() -> Array:
	return []


static func _import_packed_static(script_name: String) -> Aura:
	var script := UserClassDB.class_get_script(script_name)
	return create(script)
