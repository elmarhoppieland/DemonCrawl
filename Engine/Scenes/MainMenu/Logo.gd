extends VBoxContainer

# ==============================================================================
var timer: SceneTreeTimer
# ==============================================================================
@onready var top: TextureRect = %Top
@onready var base: Sprite2D = %Base
# ==============================================================================

func _ready() -> void:
	await start_anim()
	
	const ANIM_DURATION := 2.0
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(top, "modulate", Color.BLACK, ANIM_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_property(top, "modulate", Color.WHITE, ANIM_DURATION).set_ease(Tween.EASE_OUT)


func start_anim() -> void:
	top.modulate.a = 0
	base.modulate.a = 0
	
	timer = get_tree().create_timer(MainMenu.ANIM_WAIT)
	await timer.timeout
	timer = null
	
	const BASE_ANIM_DURATION := MainMenu.LOGO_BASE_ANIM_DURATION
	const TOP_ANIM_DURATION := MainMenu.LOGO_TOP_ANIM_DURATION
	
	var tween := create_tween()
	tween.tween_property(base, "scale", Vector2.ONE, BASE_ANIM_DURATION).from(Vector2.ONE * 3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(base, "modulate:a", 1.0, BASE_ANIM_DURATION)
	tween.tween_property(top, "modulate:a", 1.0, TOP_ANIM_DURATION)
	
	while tween.is_running():
		if Input.is_action_just_pressed("interact"):
			tween.set_speed_scale(INF)
		await get_tree().process_frame


func _process(_delta: float) -> void:
	if timer and Input.is_action_just_pressed("interact"):
		timer.time_left = 0
