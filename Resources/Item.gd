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
# ==============================================================================

func create_node(texture: CollectibleTexture = null) -> MarginContainer:
	super(texture)
	
	var color_rect := ColorRect.new()
	color_rect.color = data.get_color()
	node.add_child(color_rect)
	node.move_child(color_rect, 0)
	
	node_init()
	
	return node


func node_init() -> void:
	get_tooltip_grabber().interacted.connect(func():
		if is_active() and can_use():
			use()
			EffectManager.propagate_call("item_use", [self])
	)
	
	if data.get_color().a > 0:
		const ANIM_DURATION := 0.1
		node.mouse_entered.connect(func():
			if is_active():
				node.create_tween().tween_property(get_color_rect(), "color:a", 1.0, ANIM_DURATION)
		)
		node.mouse_exited.connect(func():
			if is_active():
				node.create_tween().tween_property(get_color_rect(), "color:a", data.get_color().a, ANIM_DURATION)
		)


func get_color_rect() -> ColorRect:
	for child in node.get_children():
		if child is ColorRect:
			return child
	
	return null


func inventory_add() -> void:
	in_inventory = true


func gain() -> void:
	pass


func lose() -> void:
	pass


func use() -> void:
	pass


func can_use() -> bool:
	return data.type in [Type.CONSUMABLE, Type.MAGIC]


func is_active() -> bool:
	return in_inventory


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


func get_atlas() -> CompressedTexture2D:
	return preload("res://Assets/sprites/items.png")


func get_atlas_region() -> Rect2:
	return data.atlas_region


func get_tooltip_text() -> String:
	return data.name


func get_tooltip_subtext() -> String:
	return data.description
