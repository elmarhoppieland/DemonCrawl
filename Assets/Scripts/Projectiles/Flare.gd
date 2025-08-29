@tool
extends Projectile
class_name Flare

# ==============================================================================

func _get_texture() -> Texture2D:
	return preload("res://Assets/Sprites/Projectiles/Flare.png")


func _cell_entered(cell: CellData) -> void:
	if cell.is_occupied() or cell.is_hidden():
		cell.open(true)
		cell.apply_aura(Burning)
		
		clear()
