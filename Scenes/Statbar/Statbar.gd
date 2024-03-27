extends MarginContainer
class_name Statbar

## The player's statbar.

# ==============================================================================
const _BUTTON_HOVER_ANIM_DURATION := 0.1
const _INVENTORY_OPEN_CLOSE_ANIM_DURATION := 0.2
# ==============================================================================
static var _instance: Statbar
static var items: Array[Item] = []
# ==============================================================================
var _inventory_button_hovered := false
var _inventory_open := false
# ==============================================================================
@onready var _inventory_icon_hover: TextureRect = %Hover
@onready var _inventory: MarginContainer = %Inventory
@onready var _item_grid: GridContainer = %ItemGrid
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _ready() -> void:
	for item in items:
		_add_item_node(item)


func _process(_delta: float) -> void:
	if _inventory_button_hovered and Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("inventory_close" if _inventory_open else "inventory_open"):
		_inventory_toggle()


func _inventory_toggle() -> void:
	_inventory.show()
	await create_tween().tween_property(_inventory, "position:x", 320 if _inventory_open else 243, _INVENTORY_OPEN_CLOSE_ANIM_DURATION)\
		.set_trans(Tween.TRANS_QUAD).finished
	_inventory_open = not _inventory_open
	_inventory.visible = _inventory_open


func _add_item_node(item: Item) -> void:
	_instance._item_grid.add_child(item.create_node())


## Adds an item to the player's inventory. Does [b]not[/b] call any methods on the item.
static func add_item(item: Item) -> void:
	items.append(item)
	_instance._add_item_node(item)


func _on_inventory_icon_mouse_entered() -> void:
	_inventory_icon_hover.modulate.a = 0
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 1, _BUTTON_HOVER_ANIM_DURATION)
	
	_inventory_button_hovered = true


func _on_inventory_icon_mouse_exited() -> void:
	_inventory_icon_hover.modulate.a = 1
	create_tween().tween_property(_inventory_icon_hover, "modulate:a", 0, _BUTTON_HOVER_ANIM_DURATION)
	
	_inventory_button_hovered = false
