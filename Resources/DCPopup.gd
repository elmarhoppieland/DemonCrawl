@tool
extends CanvasLayer
class_name DCOverlay

# ==============================================================================
const MOUSE_BLOCKER := "MouseBlocker"
const BACKGROUND_ANCHOR := "BackgroundAnchor"
const BACKGROUND_MARGIN_CONTAINER := "BackgroundAnchor/MarginContainer"
const BACKGROUND_COLOR_RECT := "BackgroundAnchor/MarginContainer/ColorRect"
const CONTENTS_ANCHOR := "ContentsAnchor"
const ANIMATION_PLAYER := "AnimationPlayer"
# ==============================================================================

func _ready() -> void:
	layer = 20
	visible = false
	transform = Transform2D(Vector2(4, 0), Vector2(0, 4), Vector2(640, 360))
	
	await get_tree().process_frame
	
	var target_owner := owner if owner else self
	
	_add_node_at_path(ColorRect, MOUSE_BLOCKER, {
		"color": Color.TRANSPARENT,
		"anchor_left": -0.125,
		"anchor_top": -0.125,
		"anchor_right": 0.125,
		"anchor_bottom": 0.125,
		"grow_horizontal": Control.GROW_DIRECTION_BOTH,
		"grow_vertical": Control.GROW_DIRECTION_BOTH,
		"owner": target_owner
	})
	_add_node_at_path(Node2D, BACKGROUND_ANCHOR, {
		"scale": Vector2(1, 0),
		"owner": target_owner
	})
	_add_node_at_path(MarginContainer, BACKGROUND_MARGIN_CONTAINER, {
		"custom_minimum_size": Vector2(320, 80),
		"anchors_preset": Control.PRESET_CENTER,
		"owner": target_owner
	})
	_add_node_at_path(ColorRect, BACKGROUND_COLOR_RECT, {
		"color": Color.BLACK,
		"owner": target_owner
	})
	_add_node_at_path(Node2D, CONTENTS_ANCHOR, {
		"modulate": Color.TRANSPARENT,
		"owner": target_owner
	})
	_add_node_at_path(AnimationPlayer, ANIMATION_PLAYER, {
		"libraries": {
			"": preload("res://Resources/DCPopupAnimationLibrary.tres")
		},
		"owner": target_owner
	})


func _add_node_at_path(base: Variant, path: String, data: Dictionary = {}) -> Node:
	if has_node(path):
		return get_node(path)
	
	if path.get_base_dir().is_empty():
		path = "./" + path
	
	var node = base.new()
	get_node(path.get_base_dir()).add_child(node)
	node.name = path.get_file()
	
	for prop in data:
		node[prop] = data[prop]
	
	return node
