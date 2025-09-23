@tool
extends CellObject
class_name Familiar

# ==============================================================================
@export var source: Texture2D = null:
	set(value):
		source = value
		emit_changed()
	get:
		if source == null:
			source = AnimatedTextureSequence.new()
			source.atlas = preload("res://assets/sprites/familiar.png")
		return source
@export var strong := false
# ==============================================================================

func _get_texture() -> Texture2D:
	return source


func _get_modulate() -> Color:
	return Color.GREEN


func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.connect(_turn)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_stage_effects().turn.disconnect(_turn)


func _turn() -> void:
	var position := get_cell().get_position()
	var dirs: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	dirs.shuffle()
	for dir in dirs:
		var new_cell := get_cell().get_stage_instance().get_cell(position + dir)
		if not can_move_to(new_cell):
			continue
		
		var was_hidden := new_cell.is_hidden()
		new_cell.reveal()
		if new_cell.has_monster():
			if strong:
				new_cell.get_object().kill()
				move_to_cell(new_cell)
			else:
				clear()
			return
		
		if not can_move_to(new_cell):
			# something has spawned that blocks our way
			return
		
		if new_cell.is_occupied():
			var object := new_cell.get_object()
			if object is Loot:
				var collected := (object as Loot).try_collect()
				if not collected:
					if was_hidden:
						return  # some loot has spawned in our way that we cannot collect
					continue
				EffectManager.propagate((get_stage_instance().get_event_bus(FamiliarEffects) as FamiliarEffects).loot_collected, [self, object])
			else:
				object.notify_interacted()
		
		move_to_cell(new_cell)
		return


func can_move_to(cell: CellData) -> bool:
	if cell == null:
		return false
	if cell.is_empty():
		return true
	if cell.has_monster():
		return strong or (cell.is_hidden() and not cell.is_flagged())
	return cell.get_object().get_script() in [Coin, Diamond, Heart]


func _get_annotation_title() -> String:
	return tr("object.familiar").to_upper()


func _get_annotation_subtext() -> String:
	if strong:
		return tr("object.familiar.strong.description")
	return tr("object.familiar.description")


func _aura_apply() -> void:
	if get_cell().get_aura() is Burning:
		kill()


func _cell_enter() -> void:
	_aura_apply()


class FamiliarEffects extends EventBus:
	signal loot_collected(familiar: Familiar, loot: Loot)
