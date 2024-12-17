@tool
extends Tree

# ==============================================================================

func _get_drag_data(_at_position: Vector2) -> Variant:
	var items: Array[TreeItem] = []
	var next: TreeItem = get_next_selected(null)
	
	var drag_preview_container := VBoxContainer.new()
	while next:
		items.append(next)
		
		var label := Label.new()
		label.text = next.get_text(0)
		drag_preview_container.add_child(label)
		
		next = get_next_selected(next)
	
	set_drag_preview(drag_preview_container)
	
	return items


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	drop_mode_flags = DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN
	
	if not data is Array or not data.all(func(a: Variant) -> bool: return a is TreeItem and a.get_tree() == self):
		return false
	
	var drop_section := get_drop_section_at_position(at_position)
	if drop_section == -100:
		return false
	
	var item := get_item_at_position(at_position)
	if item in data:
		return false
	
	if drop_section == 0 and not item.get_metadata(0).can_have_children():
		return false
	
	var parent := item.get_metadata(0).get_parent() as EffectManager.PriorityNode
	if not data.all(func(a: TreeItem) -> bool: return a.get_metadata(0).get_parent() == parent):
		return false
	
	return true


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	var other_node := other_item.get_metadata(0) as EffectManager.PriorityNode
	var items: Array[TreeItem] = []
	items.assign(data)
	
	for i in data.size():
		var item := items[i]
		var node := item.get_metadata(0) as EffectManager.PriorityNode
		node.get_parent().remove_child(node)
		match drop_section:
			-1:
				other_node.get_parent().insert_child(node, other_item.get_index())
				item.move_before(other_item)
			1:
				other_node.get_parent().insert_child(node, other_item.get_index() + i + 1)
				if i == 0:
					item.move_after(other_item)
				else:
					item.move_after(items[i - 1])
			0:
				other_node.add_child(node)
				
				item.get_parent().remove_child(item)
				other_item.add_child(item)
			_:
				assert(false, "Invalid drop_section " + str(drop_section) + ".")
