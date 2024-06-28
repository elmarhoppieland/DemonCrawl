extends MarginContainer
class_name Statbar

## The player's statbar.

# ==============================================================================
const _BUTTON_HOVER_ANIM_DURATION := 0.1
const _INVENTORY_OPEN_CLOSE_ANIM_DURATION := 0.2
# ==============================================================================
static var _instance: Statbar
# ==============================================================================
var _inventory_button_hovered := false
var _inventory_open := false
# ==============================================================================
@onready var _stats_tooltip_grabber: TooltipGrabber = %StatsTooltipGrabber
@onready var _inventory_icon_hover: TextureRect = %Hover
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory_toggle"):
		_inventory_toggle()
	if _inventory_button_hovered and Input.is_action_just_pressed("interact"):
		_inventory_toggle()


func _inventory_toggle() -> void:
	if _inventory_open:
		_animation_player.play_backwards("inventory_show")
	else:
		_animation_player.play("inventory_show")
	
	_inventory_open = not _inventory_open


static func inventory_toggle() -> void:
	_instance._inventory_toggle()


func _on_inventory_icon_mouse_entered() -> void:
	_inventory_icon_hover.modulate.a = 0
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 1, _BUTTON_HOVER_ANIM_DURATION)
	
	_inventory_button_hovered = true


func _on_inventory_icon_mouse_exited() -> void:
	_inventory_icon_hover.modulate.a = 1
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 0, _BUTTON_HOVER_ANIM_DURATION)
	
	_inventory_button_hovered = false


func _on_stats_tooltip_grabber_about_to_show() -> void:
	_stats_tooltip_grabber.text = tr("STATS_YOUR_OVERVIEW")
	_stats_tooltip_grabber.subtext = PlayerStats.get_stats_tooltip_text()
