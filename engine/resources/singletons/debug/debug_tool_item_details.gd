@tool
extends Control
class_name DebugToolItemDetails

# ==============================================================================
@export var item: ItemData :
	set(value):
		item = value
		
		if not is_node_ready():
			await ready
		
		for child in _collectible_display.get_children():
			if child is Item:
				child.queue_free()
		
		if value:
			var item_instance := value.create()
			_collectible_display.add_child(item_instance)
			_collectible_display.collectible = item_instance
			_title_label.text = value.name
			_description_label.text = value.description
		else:
			_collectible_display.collectible = null
# ==============================================================================
@onready var _title_label: Label = %TitleLabel
@onready var _collectible_display: CollectibleDisplay = %CollectibleDisplay
@onready var _description_label: Label = %DescriptionLabel
# ==============================================================================

func _get_overlay() -> DebugToolsOverlay:
	var base := get_parent()
	while base != null and base is not DebugToolsOverlay:
		base = base.get_parent()
	return base


@warning_ignore("shadowed_variable")
static func add_to_inventory(item: ItemData) -> void:
	if not Quest.has_current():
		return
	
	Quest.get_current().get_inventory().item_gain(item.create())


func _on_add_to_inventory_button_pressed() -> void:
	add_to_inventory(item)


func _on_bind_add_to_inventory_button_pressed() -> void:
	_get_overlay().bind_action(add_to_inventory.bind(item))
