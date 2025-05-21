@tool
extends Control
class_name HeirloomDisplay

# ==============================================================================
@export var slot_idx := 0 :
	set(value):
		slot_idx = value
		if not is_node_ready():
			await ready
		
		_update()
@export var active := true :
	set(value):
		active = value
		if not is_node_ready():
			await ready
		
		collectible_display.modulate = Color.WHITE.darkened(int(not value) / 2.0)
# ==============================================================================
@onready var collectible_display: CollectibleDisplay = %CollectibleDisplay
@onready var lock: TextureRect = %Lock
@onready var count_label: Label = %CountLabel
# ==============================================================================
signal interacted()
# ==============================================================================

func _ready() -> void:
	_update()
	
	Codex.heirlooms_changed.connect(_update)


func _update() -> void:
	var item := Codex.get_heirloom(slot_idx)
	collectible_display.collectible = item
	lock.visible = Codex.get_heirloom_slots() <= slot_idx
	count_label.visible = item != null
	count_label.text = str(Codex.get_heirloom_count(slot_idx))


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		if not ready.is_connected(update_minimum_size):
			ready.connect(update_minimum_size, CONNECT_ONE_SHOT)
		return Vector2(16, 16)
	
	# returns the greatest minimum size of all children, in each component separately
	return get_children().filter(func(child: Node) -> bool:
		return child is Control
	).map(func(child: Control) -> Vector2:
		return child.get_minimum_size() if child.visible else Vector2.ZERO
	).reduce(func(min_size: Vector2, value: Vector2) -> Vector2:
		return Vector2(maxf(min_size.x, value.x), maxf(min_size.y, value.y))
	)


func _on_collectible_display_interacted() -> void:
	if active:
		interacted.emit()
