@tool
extends MagicItem

# ==============================================================================
const DIRECTIONS = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]
# ==============================================================================

func _use() -> void:
	for cell in await target_cell():
		if cell.is_visible():
			for dir in DIRECTIONS:
				cell.send_projectile(BubbleProjectile, dir)


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()
