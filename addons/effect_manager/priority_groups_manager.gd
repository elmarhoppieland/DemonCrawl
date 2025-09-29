@tool
extends PopupPanel
class_name __PriorityGroupsManager

# ==============================================================================
@onready var tree: Tree = %PriorityGroupsTree

@onready var priority_group_editor: __PriorityGroupEditor = %PriorityGroupEditor
# ==============================================================================

func _ready() -> void:
	popup_window = true
	transient = true
	exclusive = true


func _on_about_to_popup() -> void:
	tree.clear()
	
	_populate_tree()


func _populate_tree() -> void:
	_populate_tree_from_base(EffectManager.get_priority_tree().root, tree.create_item())


func _populate_tree_from_base(base: EffectManager.PriorityNode, parent: TreeItem) -> void:
	for child in base.get_children():
		var item := _add_node(child, parent)
		_populate_tree_from_base(child, item)


func _add_node(node: EffectManager.PriorityNode, parent: TreeItem) -> TreeItem:
	var item := parent.create_child()
	
	item.set_text(0, node.name)
	item.set_tooltip_text(0, " ")
	
	item.set_editable(0, true)
	item.set_icon(0, node.get_icon())
	
	item.set_metadata(0, node)
	
	if node.is_editable():
		item.add_button(0, preload("res://addons/effect_manager/edit.png"))
	
	return item


func _on_create_group_button_pressed() -> void:
	var new_group := EffectManager.PriorityGroup.new()
	new_group.name = "New Group"
	
	EffectManager.get_priority_tree().root.add_child(new_group)
	
	_add_node(new_group, tree.get_root())


func _on_create_section_button_pressed() -> void:
	var new_group := EffectManager.PrioritySection.new()
	new_group.name = "New Section"
	
	EffectManager.get_priority_tree().root.add_child(new_group)
	
	_add_node(new_group, tree.get_root())


func _on_tree_item_edited() -> void:
	var item := tree.get_edited()
	match tree.get_edited_column():
		0:
			var node: EffectManager.PriorityNode = item.get_metadata(0)
			node.name = item.get_text(0)


func _on_priority_groups_tree_button_clicked(item: TreeItem, column: int, index: int, mouse_button_index: int) -> void:
	if not mouse_button_index & MOUSE_BUTTON_LEFT:
		return
	if column != 0:
		return
	
	match index:
		0:
			var node := item.get_metadata(0) as EffectManager.PriorityNode
			
			priority_group_editor.group_name = node.name
			priority_group_editor.type = node.type
			priority_group_editor.data = node.data
			priority_group_editor.popup_centered()
			
			Promise.new({
				priority_group_editor.confirmed: func() -> void:
					node.name = priority_group_editor.group_name
					node.type = priority_group_editor.type
					node.data = priority_group_editor.data
					
					item.set_text(0, node.name)
					item.set_icon(0, node.get_icon()),
				priority_group_editor.canceled: func() -> void:
					pass,
				priority_group_editor.applied: func() -> void:
					node.name = priority_group_editor.group_name
					node.type = priority_group_editor.type
					node.data = priority_group_editor.data
					
					item.set_text(0, node.name)
					item.set_icon(0, node.get_icon())
			}).map()


func _on_confirm_button_pressed() -> void:
	hide()
	
	var file := FileAccess.open("res://.data/effect_manager/priority_groups.txt", FileAccess.WRITE)
	if not file:
		push_error("Could not open file 'res://.data/effect_manager/priority_groups.txt': ", error_string(FileAccess.get_open_error()))
		return
	
	file.store_line(EffectManager.get_priority_tree().root.pack())
