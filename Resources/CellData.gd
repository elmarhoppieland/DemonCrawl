extends RefCounted
class_name CellData

## Stores data about a single [Cell].

# ==============================================================================
var theme := "" ## The cell's theme. See [member Cell.theme].
var cell_value := 0 ## The cell's value. See [member Cell.cell_value].
var revealed := false ## Whether the cell is revealed. See [member Cell.revealed].
var cell_object: CellObject ## The cell's object, if any. See [member Cell.cell_object].
# ==============================================================================

func _init() -> void:
	push_warning("CellData is deprecated.")


func _to_string() -> String:
	return str({
		"theme": theme,
		"cell_value": cell_value,
		"revealed": revealed,
		"cell_object": cell_object
	})
