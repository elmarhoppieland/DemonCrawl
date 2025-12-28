@tool
extends TextureRect
class_name TextureNodeDisplay

# ==============================================================================
@export var texture_node: TextureNode :
	set(value):
		if texture_node and texture_node.changed.is_connected(_update):
			texture_node.changed.disconnect(_update)
		
		texture_node = value
		
		_update()
		if value:
			value.changed.connect(_update)
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _update() -> void:
	texture = texture_node.get_texture() if texture_node else null
	material = texture_node.get_material() if texture_node else null


@warning_ignore("shadowed_variable")
func display_as_child(texture_node: TextureNode) -> void:
	if self.texture_node and self.texture_node.is_ancestor_of(self):
		self.texture_node.queue_free()
	
	if texture_node:
		add_child(texture_node)
	self.texture_node = texture_node
