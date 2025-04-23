@tool
extends Control
class_name StageScene

# ==============================================================================
@onready var _stage_background: StageBackground = %StageBackground : get = get_background
@onready var _finish_button: FinishButton = %FinishButton
@onready var _statbar: Statbar = %Statbar : get = get_statbar
@onready var _tweener_canvas: CanvasLayer = %TweenerCanvas
@onready var _mouse_cast_sprite: MouseCastSprite = %MouseCastSprite
@onready var _finish_popup: FinishPopup = %FinishPopup
@onready var _board: Board = %Board : get = get_board
@onready var _projectiles: Node2D = %Projectiles
# ==============================================================================

func _enter_tree() -> void:
	#_stage_instance = Stage.get_current().get_instance()
	if Stage.has_current():
		theme = Stage.get_current().get_theme()
		Stage.get_current().play_music()


#func get_stage() -> Stage:
	#return _stage_instance.stage


## Returns the scene's [StageBackground] instance.
func get_background() -> StageBackground:
	return _stage_background


## Returns the scene's [Board] instance.
func get_board() -> Board:
	if not _board and has_node("%Board"):
		_board = %Board
	return _board


func get_statbar() -> Statbar:
	if not _statbar and has_node("%Statbar"):
		_statbar = %Statbar
	return _statbar


## Returns whether the [Stage] was reloaded from the save.
func was_reloaded() -> bool:
	# TODO
	return false


## Tweens a [code]texture[/code], moving it from [code]start_pos[/code] to [code]end_pos[/code]
## in [code]duration[/code] seconds.
## [br][br]If a [code]sprite_material[/code] is specified, will add the [Material] to
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


func register_projectile(projectile: Projectile, cell_pos: Vector2i) -> ProjectileSprite:
	var sprite := ProjectileSprite.new(projectile)
	sprite.position = cell_pos * Cell.CELL_SIZE + Cell.CELL_SIZE / 2
	sprite.texture = projectile
	_projectiles.add_child(sprite)
	Quest.get_current().get_projectile_manager().register_projectile(projectile)
	return sprite


## Casts an item.
func cast(item: Item) -> Cell:
	# TODO: freeze & unfreeze board
	await _mouse_cast_sprite.cast(item)
	return get_board().get_hovered_cell()


func _on_board_stage_finished() -> void:
	Stage.get_current().get_instance().set_timer_paused(true)
	Stage.get_current().stop_music()
	_finish_button.show()


func _on_finish_button_pressed() -> void:
	_finish_button.hide()
	
	await _finish_popup.popup()
	
	Stage.get_current().finish()
	Stage.clear_current()
	
	Quest.get_current().unlock_next_stage()
	
	Eternity.save()
	
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
