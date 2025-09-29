@tool
extends Projectile
class_name Flare

# ==============================================================================

func _get_texture() -> Texture2D:
	return preload("res://assets/sprites/projectiles/flare.png")


func _cell_entered(cell: CellData) -> void:
	if cell.is_occupied() or cell.is_hidden():
		cell.reveal()
		cell.apply_aura(Burning)
		
		clear()
