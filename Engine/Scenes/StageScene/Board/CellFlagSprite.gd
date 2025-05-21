@tool
extends Sprite2D
class_name CellFlagSprite

# ==============================================================================
var _mode := Cell.Mode.HIDDEN
var _initialized := false
# ==============================================================================

func _ready() -> void:
	var cell := owner as Cell
	_mode = cell.get_mode()
	cell.theme_changed.connect(func() -> void:
		_update()
	)
	cell.mode_changed.connect(func(mode: Cell.Mode) -> void:
		_mode = mode
		_update()
	)
	_update()
	(func() -> void: _initialized = true).call_deferred()


func _update() -> void:
	const FLAG_ANIM_DURATION := 0.1
	
	texture = owner.get_theme_icon("flag", "Cell")
	
	if not _initialized:
		visible = _mode == Cell.Mode.FLAGGED
		return
	
	if _mode == Cell.Mode.FLAGGED and not visible:
		show()
		create_tween().tween_property(self, "scale", Vector2.ONE, FLAG_ANIM_DURATION).from(Vector2.ZERO)
	elif _mode != Cell.Mode.FLAGGED:
		hide()
