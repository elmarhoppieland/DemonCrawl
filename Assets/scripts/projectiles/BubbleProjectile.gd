@tool
extends Projectile
class_name BubbleProjectile

# ==============================================================================

func _get_texture() -> Texture2D:
	return preload("res://Assets/Sprites/Projectiles/Bubble.png")


func _cell_entered(cell: CellData) -> void:
	if cell.is_hidden():
		clear()
		return
	
	if cell.is_occupied():
		var object := cell.get_object()
		cell.remove_child(object)
		
		var orb := Bubble.new(object)
		var board := get_quest().get_current_stage().get_board()
		var global_position := board.get_viewport_transform() * board.get_global_at_cell_position(cell.get_position())
		Quest.get_current().get_orb_manager().register_orb(orb, global_position)
		
		clear()
