@tool
extends VBoxContainer
class_name StagesOverview

## An overview of the stages in the [Quest].

# ==============================================================================
#@export var _quest_editable := true : set = set_quest_editable, get = is_quest_editable
#@export var _quest: Quest : set = set_quest, get = get_quest
# ==============================================================================
@onready var _icon_flow_container: HFlowContainer = %IconFlowContainer
# ==============================================================================
signal icon_selected(icon: StageIcon) ## Emitted when a [StageIcon] has been selected.
# ==============================================================================

#func _validate_property(property: Dictionary) -> void:
	#if property.name == "_quest" and not is_quest_editable():
		#property.usage |= PROPERTY_USAGE_READ_ONLY


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_on_quest_changed()


func _on_quest_changed() -> void:
	if not is_node_ready():
		await ready
	
	for child in _icon_flow_container.get_children():
		child.queue_free()
	
	if not get_quest():
		return
	
	var peek_counter := 2
	for i in get_quest().stages.size():
		var stage := get_quest().stages[i]
		if not stage:
			continue
		var icon := stage.create_icon()
		_icon_flow_container.add_child(icon)
		
		if not stage.locked:
			icon.show_icon = true
			peek_counter = 2
		elif peek_counter > 0:
			icon.show_icon = true
			peek_counter -= 1
		else:
			icon.show_icon = false
		
		if not Engine.is_editor_hint():
			if i == get_quest().get_instance().selected_stage_idx:
				get_tree().process_frame.connect(icon.select.bind(true), CONNECT_ONE_SHOT)
				icon_selected.emit(icon)
			
			icon.selected.connect(func() -> void:
				get_quest().get_instance().selected_stage_idx = i
				icon_selected.emit(icon)
			)


#func set_quest_editable(quest_editable: bool = true) -> void:
	#if Engine.is_editor_hint():
		#_quest_editable = quest_editable
		#notify_property_list_changed()


#func is_quest_editable() -> bool:
	#if Engine.is_editor_hint():
		#return _quest_editable
	#return true


#func set_quest(quest: Quest) -> void:
	#if Engine.is_editor_hint() and _quest and _quest.changed.is_connected(_on_quest_changed):
		#_quest.changed.disconnect(_on_quest_changed)
	#
	#_quest = quest
	#
	#if Engine.is_editor_hint() and quest:
		#quest.changed.connect(_on_quest_changed)
	#
	#_on_quest_changed()


func get_quest() -> Quest:
	return Quest.get_current()
