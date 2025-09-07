@tool
extends Control
class_name OrbLayer

# ==============================================================================
var _loaded_orbs: Dictionary[Orb, OrbSprite] = {}
# ==============================================================================
@onready var _orb_parent: Control = %OrbParent
# ==============================================================================

func _ready() -> void:
	while true:
		_load_from_current_quest()
		await Quest.current_changed


func _load_from_current_quest() -> void:
	_clear()
	
	if not Quest.has_current():
		return
	
	var orb_manager := Quest.get_current().get_orb_manager()
	
	for orb in orb_manager.get_orbs():
		_register_orb(orb)
	
	orb_manager.orb_registered.connect(_register_orb)
	await Quest.current_changed
	orb_manager.orb_registered.disconnect(_register_orb)


@warning_ignore("shadowed_variable_base_class")
func _register_orb(orb: Orb, screen_position: Vector2 = _orb_parent.position) -> void:
	if orb not in _loaded_orbs:
		var sprite := orb.create_sprite()
		sprite.position = _orb_parent.get_global_transform().affine_inverse() * screen_position
		_orb_parent.add_child(sprite)
		_loaded_orbs[orb] = sprite
		
		sprite.half_bounds = Rect2(Vector2.ZERO, size * 0.5 / _orb_parent.scale)
		
		orb.cleared.connect(sprite.queue_free)


func _clear() -> void:
	_loaded_orbs.clear()
	
	for child in _orb_parent.get_children():
		assert(child is OrbSprite, "Invalid child found as the orbs' parent: OrbSprite expected, found %s." % UserClassDB.script_get_identifier(child.get_script()))
		child.queue_free()
