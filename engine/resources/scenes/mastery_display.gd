@tool
extends Control
class_name MasteryDisplay

# ==============================================================================
@export var charge_color := Color(0.235, 0.624, 0.984)

@export var mastery: Mastery = null :
	set(value):
		if mastery and mastery.changed.is_connected(_update):
			mastery.changed.disconnect(_update)
		
		mastery = value
		
		_update()
		if value and not value.changed.is_connected(_update):
			value.changed.connect(_update)
# ==============================================================================
var _blink_tween: Tween = null :
	set(value):
		if _blink_tween and value != _blink_tween:
			_blink_tween.kill()
		_blink_tween = value
# ==============================================================================
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _charges_anchor: Node2D = %ChargesAnchor
@onready var _charges_container: HBoxContainer = %ChargesContainer
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================

@warning_ignore("shadowed_variable")
static func create(mastery: Mastery, add_as_child: bool = false) -> MasteryDisplay:
	var instance: MasteryDisplay = load("res://engine/resources/scenes/mastery_display.tscn").instantiate()
	instance.mastery = mastery
	if add_as_child:
		instance.add_child(mastery)
	return instance


func _update() -> void:
	if not is_node_ready():
		await ready
	
	if not mastery:
		_texture_rect.texture = null
		_charges_anchor.hide()
		return
	
	_texture_rect.texture = mastery.get_icon()
	_tooltip_grabber.text = mastery.get_name_text()
	_tooltip_grabber.subtext = mastery.get_description_text()
	if mastery.level >= 3 and mastery.get_data().ability_charges > 0 and mastery.get_charges() > 0:
		_charges_anchor.show()
		
		for i in mastery.get_data().ability_charges:
			var charge: ColorRect
			if i < _charges_container.get_child_count():
				charge = _charges_container.get_child(i)
			else:
				charge = ColorRect.new()
				charge.color = charge_color
				charge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				_charges_container.add_child(charge)
			
			if mastery.get_charges() > i:
				charge.modulate.a = 1
			else:
				charge.modulate.a = 0
		
		for i in range(mastery.get_data().ability_charges, _charges_container.get_child_count()):
			_charges_container.get_child(i).queue_free()
		
		if mastery.is_charged() and mastery.active:
			if not _blink_tween:
				const GLOW_DURATION := 0.3
				const GLOW_WAIT := 0.5
				
				var shader := _texture_rect.material as ShaderMaterial
				
				_blink_tween = create_tween().set_loops()
				_blink_tween.tween_method(func(glow: float) -> void:
					shader.set_shader_parameter("glow", glow)
				, 0.0, 0.5, GLOW_DURATION)
				_blink_tween.tween_method(func(glow: float) -> void:
					shader.set_shader_parameter("glow", glow)
				, 0.5, 0.0, GLOW_DURATION)
				_blink_tween.tween_interval(GLOW_WAIT)
		else:
			_blink_tween = null
			_texture_rect.material.set_shader_parameter("glow", 0.0)
	else:
		_charges_anchor.hide()
		_blink_tween = null
		_texture_rect.material.set_shader_parameter("glow", 0.0)
	
	update_minimum_size()


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		return Vector2.ZERO
	return _texture_rect.get_minimum_size()


func _on_interacted() -> void:
	if mastery and mastery.active:
		mastery.use_ability()
