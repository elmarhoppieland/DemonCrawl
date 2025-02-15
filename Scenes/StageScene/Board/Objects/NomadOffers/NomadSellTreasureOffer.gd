extends NomadSellOffer
class_name NomadSellTreasureOffer

# ==============================================================================

func _spawn() -> void:
	cost = randi_range(5, 10)


func _perform() -> void:
	super()
	
	_nomad.get_cell().spawn(CellObjectBase.new(CellChest), true)
