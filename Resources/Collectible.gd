extends RefCounted
class_name Collectible

# ==============================================================================
var node: Control :
	set(value):
		if node == value:
			return
		
		remove_node_from_tree()
		
		node = value
# ==============================================================================

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(node):
			node.queue_free()


## Creates a new [member node] and returns it. The new node is stored in [member node],
## and the old node (if any) will be immediately removed from the tree and freed at the
## end of the frame (see [method Node.queue_free]).
## [br][br]Child scripts should override this method if a different node hierarchy
## is needed. [code]super()[/code] can be called to keep the default behaviour.
func create_node() -> MarginContainer:
	var texture := CollectibleTexture.new()
	texture.collectible = self
	
	node = MarginContainer.new()
	
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	node.add_child(texture_rect)
	
	var tooltip_grabber := TooltipGrabber.new()
	tooltip_grabber.text = get_tooltip_text()
	tooltip_grabber.subtext = get_tooltip_subtext()
	node.add_child(tooltip_grabber)
	
	return node


## Duplicates the [Collectible], returning a new instance of the same [Script].
## [br][br][b]Note:[/b] This object's properties will [b]not[/b] be copied over.
## The new object will have its own [member node] and will generate new instances
## of any other properties defined by its child script(s).
func duplicate() -> Collectible:
	return get_script().new()


## Returns this [Collectible]'s [member node]. Creates a new node if it does not have one,
## or if the current one has been freed.
func get_node() -> MarginContainer:
	if not is_instance_valid(node):
		create_node()
	
	return node


## Returns the [member node]'s [TooltipGrabber], if it has one.
func get_tooltip_grabber() -> TooltipGrabber:
	for child in node.get_children():
		if child is TooltipGrabber:
			return child
	
	return null


## Returns the [member node]'s [TextureRect], if it has one.
func get_texture_rect() -> TextureRect:
	for child in node.get_children():
		if child is TextureRect:
			return child
	
	return null


## Returns the [SceneTree] the [member node] is in.
func get_tree() -> SceneTree:
	return node.get_tree() if is_instance_valid(node) and node.is_inside_tree() else null


## Returns the atlas used for this collectible. Should be overridden by child
## scripts.
func get_atlas() -> Texture2D:
	return null


## Returns the region of the atlas (see [method get_atlas]) used for this collectible.
## Should be overridden by child scripts.
func get_atlas_region() -> Rect2:
	return Rect2()


## Returns the text used in the [Tooltip] when the player hovers the [member node].
func get_tooltip_text() -> String:
	return ""


## Returns the subtext used in the [Tooltip] when the player hovers the [member node].
func get_tooltip_subtext() -> String:
	return ""


## Immediately removes the [member node] from the scene tree. If [code]keep_node[/code]
## is [code]false[/code], also frees the node at the end of the frame.
## [br][br]Is always safe to call. If the node is [code]null[/code] or already freed,
## calling this method does nothing. If the node exists but is not in the scene tree,
## the node will simply be freed (if [code]keep_node[/code] is [code]false[/code]).
func remove_node_from_tree(keep_node: bool = false) -> void:
	if not is_instance_valid(node):
		return
	
	if node.is_inside_tree():
		node.get_parent().remove_child(node)
	
	if not keep_node:
		node.queue_free()


## Creates a new [StatusEffect]. Uses the given [code]uid[/code] if specified.
func create_status(uid: String = "") -> StatusEffect.Initializer:
	return StatusEffect.create(uid).set_source(self)


## Returns the path where this [Collectible] is located in the filesystem.
func get_path() -> String:
	return get_script().resource_path.get_basename()
