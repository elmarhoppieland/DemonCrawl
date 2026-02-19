@tool
extends Control
class_name StageScene

# ==============================================================================
static var _instance: StageScene = null : get = get_instance
# ==============================================================================
@export var stage_instance: StageInstance = null :
	set(value):
		stage_instance = value
		if value.is_completed():
			await ready
			_on_stage_completed()
		else:
			value.get_effects().completed.connect(_on_stage_completed)
		
		if not is_node_ready():
			await ready
		
		AudioBus.play_music(value.get_stage().file.music)
		AudioBus.play_ambience(value.get_stage().file.ambience_a, value.get_stage().file.ambience_b)
		
		theme = value.get_stage().get_theme()
# ==============================================================================
@onready var _stage_background: StageBackground = %StageBackground : get = get_background
@onready var _finish_button: FinishButton = %FinishButton
@onready var _menu_return_button: FinishButton = %MenuReturnButton
@onready var _tweener_canvas: CanvasLayer = %TweenerCanvas
@onready var _mouse_cast_sprite: MouseCastSprite = %MouseCastSprite
@onready var _finish_popup: FinishPopup = %FinishPopup
@onready var _status_effect_list: StatusEffectList = %StatusEffectList
@onready var _board: Board = %Board : get = get_board
@onready var _projectiles: Node2D = %Projectiles
# ==============================================================================
signal finish_pressed()
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for projectile in stage_instance.get_projectile_manager().get_projectiles():
		register_projectile(projectile)
	
	_status_effect_list.manager = Quest.get_current().get_status_manager()


## Returns the scene's [StageBackground] instance.
func get_background() -> StageBackground:
	return _stage_background


## Returns the scene's [Board] instance.
func get_board() -> Board:
	if not _board and has_node("%Board"):
		_board = %Board
	return _board


## Returns whether the [Stage] was reloaded from the save.
func was_reloaded() -> bool:
	# TODO
	return false


## Tweens a [param texture], moving it from [param start_pos] to [param end_pos]
## in [param duration] seconds.
## [br][br]If a [param sprite_material] is specified, will add the [Material] to
## the [Sprite2D].
## [br][br]Returns the created [Sprite2D] object.
func tween_texture(texture: Texture2D, start_pos: Vector2, end_pos: Vector2, duration: float, sprite_material: Material = null) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.scale = get_board().get_camera().zoom
	
	sprite.texture = texture
	sprite.material = sprite_material
	
	_tweener_canvas.add_child(sprite)
	
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "position", end_pos, duration).from(start_pos)
	tween.tween_callback(sprite.queue_free)
	return sprite


func register_projectile(projectile: Projectile) -> ProjectileSprite:
	var sprite := ProjectileSprite.new(projectile)
	sprite.global_position = get_board().get_global_at_cell_position(projectile.position) * _projectiles.get_global_transform()
	sprite.texture = projectile.get_texture()
	_projectiles.add_child(sprite)
	if projectile not in stage_instance.get_projectile_manager().get_projectiles():
		stage_instance.get_projectile_manager().register_projectile(projectile)
	return sprite


## Casts an item.
func cast(icon: Texture2D) -> CellData:
	# TODO: freeze & unfreeze board
	var r := await _mouse_cast_sprite.cast(icon)
	if not r:
		return null
	var cell := get_board().get_cell_at_global(get_board().get_global_mouse_position())
	return cell.get_data() if cell else null


func _on_stage_completed() -> void:
	AudioBus.stop_music()
	stage_instance.get_timer().pause()
	stage_instance.get_status_timer().pause()
	_finish_button.show_button()


func _on_board_stage_finished() -> void:
	_on_stage_completed()


func _on_finish_button_pressed() -> void:
	_finish_button.hide()
	finish_pressed.emit()
	AudioBus.stop_ambience()
	
	stage_instance.notify_finish_pressed()
	
	await _finish_popup.popup()
	
	stage_instance.finish()


func show_menu_return() -> void:
	_menu_return_button.show_button()


func _on_menu_return_button_pressed() -> void:
	_menu_return_button.hide()
	
	stage_instance.get_quest().queue_free()
	
	get_tree().change_scene_to_file("res://engine/scenes/main_menu/main_menu.tscn")


static func get_instance() -> StageScene:
	return _instance
