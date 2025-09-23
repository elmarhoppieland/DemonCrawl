@tool
extends MarginContainer
class_name Statbar

## The player's statbar.

# ==============================================================================
const _BUTTON_HOVER_ANIM_DURATION := 0.1
const _INVENTORY_OPEN_CLOSE_ANIM_DURATION := 0.2
# ==============================================================================
@export var quest: Quest = null :
	set(value):
		quest = value
		
		_mastery_display.mastery = value.get_mastery() if value else null
		_stats.stats = value.get_stats() if value else null
		_inventory.inventory = value.get_inventory() if value else null
# ==============================================================================
#var _inventory_button_hovered := false
var _inventory_open := false : get = is_inventory_open
# ==============================================================================
@onready var _stats_tooltip_grabber: TooltipGrabber = %StatsTooltipGrabber
@onready var _mastery_display: MasteryDisplay = %MasteryDisplay
@onready var _stats: StatsDisplay = %StatsDisplay
#@onready var _inventory_icon_hover: TextureRect = %Hover
@onready var _heirloom_displays: Array[HeirloomDisplay] = [%HeirloomDisplay1, %HeirloomDisplay2, %HeirloomDisplay3]
@onready var _inventory: Inventory = %Inventory
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

#func _ready() -> void:
	#Quest.current_changed.connect(_current_quest_changed)


#func _current_quest_changed() -> void:
	#if not Quest.has_current():
		#return
	#
	#var quest := Quest.get_current()
	#quest.changed.connect(_update_heirloom_activity)
	#_update_heirloom_activity()
	#
	#await Quest.current_changed
	#quest.changed.disconnect(_update_heirloom_activity)


func _update_heirloom_activity() -> void:
	for heirloom_display in _heirloom_displays:
		heirloom_display.active = Quest.get_current().heirlooms_active


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("inventory_toggle"):
		inventory_toggle()
	#if _inventory_button_hovered and Input.is_action_just_pressed("interact"):
		#inventory_toggle()


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


#func _on_inventory_icon_mouse_entered() -> void:
	#create_tween().tween_property(_inventory_icon_hover, "modulate:a", 1, _BUTTON_HOVER_ANIM_DURATION).from(0.0)
	#
	#_inventory_button_hovered = true


#func _on_inventory_icon_mouse_exited() -> void:
	#create_tween().tween_property(_inventory_icon_hover, "modulate:a", 0, _BUTTON_HOVER_ANIM_DURATION).from(1.0)
	#
	#_inventory_button_hovered = false


func _on_stats_tooltip_grabber_about_to_show() -> void:
	_stats_tooltip_grabber.subtext = Quest.get_current().get_attributes().get_overview_text()


func _on_heirloom_display_interacted(slot_idx: int) -> void:
	var item := Codex.use_heirloom(slot_idx).duplicate()
	Quest.get_current().heirlooms_active = false
	Quest.get_current().get_inventory().item_gain(item)


func is_inventory_open() -> bool:
	return _inventory_open
