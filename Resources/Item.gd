extends Collectible
class_name Item

# ==============================================================================
enum Type {
	PASSIVE,
	CONSUMABLE,
	MAGIC,
	LEGENDARY,
	OMEN,
	MAX
}
# ==============================================================================
const COLOR_CONSUMABLE := Color("14a46480")
const COLOR_PASSIVE := Color("00000000")
const COLOR_MAGIC := Color("2a6eb080")
const COLOR_OMEN := Color("bc383880")
const COLOR_LEGENDARY := Color("b3871a80")
# ==============================================================================
var data: ItemData :
	get:
		if not data:
			data = ResourceLoader.load(get_script().resource_path.get_basename() + ".tres")
		return data

var in_inventory := false
var current_mana := 0 : set = set_mana
# ==============================================================================

func create_node() -> ItemIcon:
	node = ItemIcon.create(data)
	get_node().current_mana = current_mana
	
	node_init()
	
	return node


func node_init() -> void:
	get_node().interacted.connect(func():
		if is_active() and can_use():
			use()
			EffectManager.propagate_call("item_use", [self])
	)
	
	if data.get_color().a > 0:
		const ANIM_DURATION := 0.1
		get_node().mouse_entered.connect(func():
			if is_active():
				get_node().create_tween().tween_property(get_color_rect(), "color:a", 1.0, ANIM_DURATION)
		)
		get_node().mouse_exited.connect(func():
			if is_active():
				get_node().create_tween().tween_property(get_color_rect(), "color:a", data.get_color().a, ANIM_DURATION)
		)


func get_color_rect() -> ColorRect:
	for child in get_node().get_children():
		if child is ColorRect:
			return child
	
	return null


func inventory_add() -> void:
	in_inventory = true


func gain() -> void:
	if data.type == Type.MAGIC:
		current_mana = data.mana


func lose() -> void:
	pass


func use() -> void:
	pass


func can_use() -> bool:
	if data.type == Type.CONSUMABLE:
		return true
	if data.type == Type.MAGIC and current_mana >= data.mana:
		return true
	
	return false


## Returns whether this item can recieve mana (i.e. it uses mana and the maximum
## mana is not yet reached).
func can_recieve_mana() -> bool:
	return has_mana() and current_mana < data.mana


## Returns whether this item uses mana.
func has_mana() -> bool:
	return data.mana


## Returns whether this item is charged, i.e. it uses mana and is at its maximum mana.
func is_charged() -> bool:
	return has_mana() and current_mana >= data.mana


## Returns whether this item is active, i.e. its effects apply. This is usually
## true if the item is in the player's inventory and false if not.
func is_active() -> bool:
	return in_inventory


## Constructs a new item from the given path.
static func from_path(path: String) -> Item:
	if path.is_relative_path():
		path = "res://Assets/items/".path_join(path)
	
	return ResourceLoader.load(path.get_basename() + ".gd").new()


func clear() -> void:
	Inventory.remove_item(self)


func transform(new_item: Item) -> void:
	Inventory.transform_item(self, new_item)


func target_cell() -> Cell:
	var cells := await target_cells(1)
	if cells.is_empty():
		return null
	return cells[0]


func target_cells(radius: int) -> Array[Cell]:
	if not Board.exists():
		return []
	
	MouseCastSprite.cast(self)
	
	while true:
		await get_tree().process_frame
		
		if Input.is_action_just_pressed("secondary_interact"):
			return []
		
		if Cell.get_hovered_cell():
			var cells: Array[Cell] = []
			var topleft := Cell.get_hovered_cell().board_position - (radius - 1) * Vector2i.ONE
			for offset_y in radius * 2 - 1:
				var y := topleft.y + offset_y
				if y < 0 or y >= Board.board_size.y:
					continue
				for offset_x in radius * 2 - 1:
					var x := topleft.x + offset_x
					if x < 0 or x >= Board.board_size.x:
						continue
					
					cells.append(Board.get_cell(Vector2i(x, y)))
			
			if Input.is_action_just_pressed("interact"):
				return cells
	
	return []


func set_mana(mana: int) -> void:
	mana = clampi(mana, 0, data.mana)
	current_mana = mana
	get_node().current_mana = mana


func gain_mana(mana: int) -> void:
	current_mana += mana


func clear_mana() -> void:
	current_mana -= data.mana


func get_atlas() -> CompressedTexture2D:
	return preload("res://Assets/sprites/items.png")


func get_atlas_region() -> Rect2:
	return data.atlas_region


func get_tooltip_text() -> String:
	return data.name


func get_tooltip_subtext() -> String:
	return data.description


func get_node() -> ItemIcon:
	return super() # for autocomplete


func _export() -> Dictionary:
	var dict := {
		"path": get_path()
	}
	
	if data.mana:
		dict.mana = current_mana
	
	return dict


static func _import(value: Dictionary) -> Item:
	assert("path" in value)
	
	var item := Item.from_path(value.path)
	if "mana" in value:
		item.current_mana = value.mana
	return item
