extends Object
class_name Minesweeper

## A singleton that generates minesweeper boards.

# ==============================================================================

## Generates a random board with the given [code]size[/code] and number of [code]mines[/code] (monsters).
## Applies the given [code]theme[/code] to each [CellData] object.
## [br][br]If [code]rng[/code] is provided, uses the given [RandomNumberGenerator] to generate the board.
## Otherwise, uses the functions in [@GlobalScope].
static func generate_board(size: Vector2i, mines: int, theme: String, rng: RandomNumberGenerator = null) -> Dictionary:
	var mine_positions := generate_mines(size, mines, rng)
	
	var board := {}
	
	var cell_positions: Array[Vector2i] = []
	for x in size.x:
		for y in size.y:
			cell_positions.append(Vector2i(x, y))
	
	for cell_position in cell_positions:
		var data := CellData.new()
		data.theme = "res://Assets/skins".path_join(theme)
		
		if cell_position in mine_positions:
			data.cell_object = CellMonster.new()
		
		board[cell_position] = data
	
	return board


## Generates random mine positions for a board of the given [code]size[/code] and number of [code]mines[/code].
## [br][br]If [code]rng[/code] is provided, uses the given [RandomNumberGenerator] to generate the board.
## Otherwise, uses the functions in [@GlobalScope].
static func generate_mines(size: Vector2i, mines: int, rng: RandomNumberGenerator = null) -> Array[Vector2i]:
	var mine_positions: Array[Vector2i] = []
	
	while mine_positions.size() < mines:
		var position := Vector2i.ZERO
		if rng:
			position = Vector2i(rng.randi_range(0, size.x - 1), rng.randi_range(0, size.y - 1))
		else:
			position = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1))
		
		if not position in mine_positions:
			mine_positions.append(position)
	
	return mine_positions
