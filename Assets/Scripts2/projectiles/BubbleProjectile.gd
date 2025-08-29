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
		var orb := Bubble.new(cell.get_object())
		get_quest().get_orb_manager().register_orb(orb)
		
		clear()
