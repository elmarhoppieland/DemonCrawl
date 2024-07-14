extends RefCounted
class_name CellEnchantment

# ==============================================================================
var cell: Cell
# ==============================================================================

func _init(_cell: Cell) -> void:
	cell = _cell
	
	EffectManager.register_object(self, EffectManager.Priority.ITEM, 0) # TODO: determine subpriority
