@tool
extends Node
class_name GuiEnabler

# ==============================================================================
const GUI_LAYER_SCENE := preload("res://Engine/Resources/Singletons/GuiLayer.tscn")
# ==============================================================================
@export var enabled := 0 :
	set(value):
		_disabled = GuiEnabler.invert_bits(value, GuiEnabler.get_gui_list().size())
	get:
		return GuiEnabler.invert_bits(_disabled, GuiEnabler.get_gui_list().size())
# ==============================================================================
var _disabled := 0 :
	set(value):
		var diff := _disabled ^ value
		_disabled = value
		
		if Engine.is_editor_hint():
			var i := 0
			while diff:
				if diff & 1:
					var gui_name := GuiEnabler.get_gui_list()[i]
					
					if value & 1:
						if _editor_gui_layer_placeholder.has_node(gui_name):
							var gui_instance := _editor_gui_layer_placeholder.get_node(gui_name)
							gui_instance.queue_free()
					else:
						if GuiEnabler.has_gui_node(gui_name):
							var gui_instance := GuiEnabler.get_gui_branch(gui_name)
							_editor_gui_layer_placeholder.add_child(gui_instance)
				
				i += 1
				diff >>= 1
				value >>= 1

var _editor_gui_layer_placeholder: CanvasLayer :
	get:
		if not _editor_gui_layer_placeholder and Engine.is_editor_hint():
			for child in get_children():
				if child is CanvasLayer and child.layer == 50:
					_editor_gui_layer_placeholder = child
					return child
			
			_editor_gui_layer_placeholder = CanvasLayer.new()
			_editor_gui_layer_placeholder.layer = 50
			add_child(_editor_gui_layer_placeholder)
		
		return _editor_gui_layer_placeholder
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"enabled":
			property.usage &= ~PROPERTY_USAGE_STORAGE
			property.hint = PROPERTY_HINT_FLAGS
			property.hint_string = ",".join(GuiEnabler.get_gui_list())
		&"_disabled":
			property.usage |= PROPERTY_USAGE_STORAGE


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	var e := enabled # create a local copy so we can modify it without modifying the actual property
	
	var i := 0
	while e:
		if e & 1:
			var gui_name := GuiEnabler.get_gui_list()[i]
			var node := GuiLayer.get_instance().get_node(gui_name)
			if node.has_method("show"):
				node.show()
		
		i += 1
		e >>= 1


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	var e := enabled # create a local copy so we can modify it without modifying the actual property
	
	var i := 0
	while e:
		if e & 1:
			var gui_name := GuiEnabler.get_gui_list()[i]
			var node := GuiLayer.get_instance().get_node(gui_name)
			if node.has_method("hide"):
				node.hide()
		
		i += 1
		e >>= 1


static func get_gui_list() -> PackedStringArray:
	var child_list := PackedStringArray()
	
	var state := load("res://Engine/Resources/Singletons/GuiLayer.tscn").get_state() as SceneState
	for i in state.get_node_count():
		var parent_path := state.get_node_path(i, true)
		if parent_path == ^".":
			child_list.append(state.get_node_name(i))
	
	return child_list


static func get_gui_branch(gui_name: String) -> Node:
	var instance := load("res://Engine/Resources/Singletons/GuiLayer.tscn").instantiate() as Node
	var branch := instance.get_node(gui_name)
	instance.remove_child(branch)
	branch.owner = null
	instance.queue_free()
	return branch


static func has_gui_node(gui_name: String) -> bool:
	var state := load("res://Engine/Resources/Singletons/GuiLayer.tscn").get_state() as SceneState
	
	for i in state.get_node_count():
		if state.get_node_name(i) == gui_name:
			return true
	
	return false


static func invert_bits(bits: int, size: int) -> int:
	for i in size:
		bits ^= 1 << i
	return bits
