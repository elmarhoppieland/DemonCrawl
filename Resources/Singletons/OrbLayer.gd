extends Control
class_name OrbLayer

# ==============================================================================
var _loaded_orbs: Array[Orb] = []
# ==============================================================================
@onready var _orb_parent: Control = %OrbParent
# ==============================================================================

func _ready() -> void:
	while true:
		if Quest.has_current():
			_load_from_current_quest()
		else:
			_clear()
		await Quest.current_changed


func _load_from_current_quest() -> void:
	_loaded_orbs.clear()
	
	var orb_manager := Quest.get_current().get_orb_manager()
	
	for orb in orb_manager.orbs:
		_register_orb(orb)
	
	orb_manager.orb_registered.connect(_register_orb)
	await Quest.current_changed
	orb_manager.orb_registered.disconnect(_register_orb)


@warning_ignore("shadowed_variable_base_class")
func _register_orb(orb: Orb, global_position: Vector2 = Vector2.ZERO) -> void:
	if orb not in _loaded_orbs:
		var sprite := orb.create_sprite()
		sprite.global_position = global_position
		_orb_parent.add_child(sprite)
		_loaded_orbs.append(orb)
		
		sprite.half_bounds = Rect2(Vector2.ZERO, size * 0.5 / _orb_parent.scale)


func _clear() -> void:
	_loaded_orbs.clear()
	
	for child in _orb_parent.get_children():
		assert(child is OrbSprite, "Invalid child found as the orbs' parent: OrbSprite expected, found %s." % UserClassDB.script_get_identifier(child.get_script()))
		child.queue_free()
