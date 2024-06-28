extends Object
class_name Minesweeper

## A singleton that generates minesweeper boards.

# ==============================================================================

## Generates random mine positions for a board of the given [code]size[/code] and number of [code]mines[/code].
## [br][br]If [code]rng[/code] is provided, uses the given [RandomNumberGenerator] to generate the board.
## Otherwise, uses the functions in [@GlobalScope].
static func generate_mines(size: Vector2i, mines: int, open_position: Vector2i, rng: RandomNumberGenerator = null) -> PackedInt32Array:
	var mine_positions: PackedInt32Array = []
	
	while mine_positions.size() < mines:
		var x := RNG.randi_range(0, size.x - 1, rng)
		var y := RNG.randi_range(0, size.y - 1, rng)
		
		if x >= open_position.x - 1 and x <= open_position.x + 1 and y >= open_position.y - 1 and y <= open_position.y + 1:
			continue
		
		var index := x + y * size.x
		
		if not index in mine_positions:
			mine_positions.append(index)
	
	return mine_positions
