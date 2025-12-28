extends CanvasLayer
class_name DebugToolsOverlay

# ==============================================================================
const SETTINGS_PATH := "user://dev/settings.ini"
# ==============================================================================
var actions: Dictionary[InputEvent, Callable] = {}
# ==============================================================================
@onready var _panel_container: PanelContainer = %PanelContainer
@onready var _debug_tools_container: HFlowContainer = %DebugToolsContainer
@onready var _items_container: HFlowContainer = %ItemsContainer
@onready var _item_details_container: MarginContainer = %ItemDetailsContainer

@onready var _input_binder: InputBinder = %InputBinder

@onready var selected_tool_button: DebugToolButton = _debug_tools_container.get_child(0)
# ==============================================================================

func _ready() -> void:
	hide()
	_panel_container.hide()
	
	_on_debug_tool_pressed(selected_tool_button)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"debug_tools_overlay_toggle"):
		if visible:
			hide()
			_panel_container.hide()
			get_tree().paused = false
		else:
			show()
			_panel_container.show()
			get_tree().paused = true


func _input(event: InputEvent) -> void:
	if event.is_released():
		return
	
	for action_event in actions:
		if event.is_match(action_event):
			actions[action_event].call()


func select_item(item: Control) -> void:
	var details := selected_tool_button.handle_item_selected(item)
	if _item_details_container.is_ancestor_of(details):
		return
	
	for child in _item_details_container.get_children():
		child.queue_free()
	_item_details_container.add_child(details)


func bind_action(action: Callable) -> void:
	_input_binder.show()
	
	var event: InputEvent = await Promise.list(_input_binder.event_selected, _input_binder.cancelled).any()
	
	if event:
		for action_event in actions:
			if action_event.is_match(event):
				actions.erase(action_event)
		
		actions[event] = action


func _on_debug_tool_pressed(tool: DebugToolButton) -> void:
	if selected_tool_button and selected_tool_button.item_selected.is_connected(select_item):
		selected_tool_button.item_selected.disconnect(select_item)
	
	for child in _items_container.get_children():
		child.queue_free()
	
	selected_tool_button = tool
	
	for item in tool.get_items():
		_items_container.add_child(item)
	
	tool.item_selected.connect(select_item)


func _on_search_box_timeout(search: String) -> void:
	var items: Array[Control] = []
	items.assign(_items_container.get_children())
	selected_tool_button.handle_search(search, items)


func _on_clear_bound_button_pressed() -> void:
	actions.clear()
