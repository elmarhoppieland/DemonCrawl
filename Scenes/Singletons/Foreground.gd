extends CanvasLayer

# ==============================================================================

func _ready() -> void:
	$ColorRect.color.a = 0


func fade_out(duration: float = 1.0, tween: Tween = null) -> PropertyTweener:
	return (tween if tween else create_tween()).tween_property($ColorRect, "color:a", 1.0, duration).from(0.0)


func fade_in(duration: float = 1.0, tween: Tween = null) -> PropertyTweener:
	return (tween if tween else create_tween()).tween_property($ColorRect, "color:a", 0.0, duration).from(1.0)


func fade_out_in(duration: float = 1.0) -> Tween:
	var tween := create_tween()
	fade_out(duration, tween)
	fade_in(duration, tween)
	return tween
