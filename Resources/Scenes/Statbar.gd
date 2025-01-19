extends MarginContainer
class_name Statbar

## The player's statbar.

# ==============================================================================
const _BUTTON_HOVER_ANIM_DURATION := 0.1
const _INVENTORY_OPEN_CLOSE_ANIM_DURATION := 0.2
# ==============================================================================
var _inventory_button_hovered := false
var _inventory_open := false
# ==============================================================================
#@onready var _stats_tooltip_grabber: TooltipGrabber = %StatsTooltipGrabber
@onready var _stats: Stats = %Stats
@onready var _inventory_icon_hover: TextureRect = %Hover
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory_toggle"):
		inventory_toggle()
	if _inventory_button_hovered and Input.is_action_just_pressed("interact"):
		inventory_toggle()


func inventory_toggle() -> void:
	if _inventory_open:
		_animation_player.play_backwards("inventory_show")
	else:
		_animation_player.play("inventory_show")
	
	_inventory_open = not _inventory_open


func get_coin_position() -> Vector2:
	return _stats.get_coin_position()


func get_heart_position() -> Vector2:
	return _stats.get_heart_position()


func _on_inventory_icon_mouse_entered() -> void:
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 1, _BUTTON_HOVER_ANIM_DURATION).from(0.0)
	
	_inventory_button_hovered = true


func _on_inventory_icon_mouse_exited() -> void:
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 0, _BUTTON_HOVER_ANIM_DURATION).from(1.0)
	
	_inventory_button_hovered = false


func _on_stats_tooltip_grabber_about_to_show() -> void:
	pass
	#_stats_tooltip_grabber.subtext = Stats.get_stats_tooltip_text()
