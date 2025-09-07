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
			stage_instance.get_effects().completed.connect(_on_stage_completed)
# ==============================================================================
@onready var _stage_background: StageBackground = %StageBackground : get = get_background
@onready var _finish_button: FinishButton = %FinishButton
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
	
	if stage_instance:
		stage_instance.get_stage().stop_music()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if stage_instance:
		theme = stage_instance.get_stage().get_theme()
		stage_instance.get_stage().play_music()
	
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


func register_projectile(projectile: Projectile) -> ProjectileSprite:
	var sprite := ProjectileSprite.new(projectile)
	sprite.global_position = get_board().get_global_at_cell_position(projectile.position) * _projectiles.get_global_transform()
	sprite.texture = projectile.get_texture()
	_projectiles.add_child(sprite)
	if projectile not in stage_instance.get_projectile_manager().get_projectiles():
		stage_instance.get_projectile_manager().register_projectile(projectile)
	return sprite


## Casts an item.
func cast(item: Item) -> CellData:
	# TODO: freeze & unfreeze board
	await _mouse_cast_sprite.cast(item)
	return get_board().get_hovered_cell().get_data()


func _on_stage_completed() -> void:
	stage_instance.get_timer().pause()
	stage_instance.get_status_timer().pause()
	stage_instance.get_stage().stop_music()
	_finish_button.show()


func _on_board_stage_finished() -> void:
	_on_stage_completed()


func _on_finish_button_pressed() -> void:
	_finish_button.hide()
	finish_pressed.emit()
	
	stage_instance.notify_finish_pressed()
	
	await _finish_popup.popup()
	
	stage_instance.finish()
	
	#var quest := Quest.get_current()
	#stage_instance.notify_unloaded()
	#quest.notify_stage_finished(stage_instance)
	
	stage_instance.get_stage().stop_music()
	
	#if quest.is_finished():
		#await quest.finish()
		#
		#Quest.clear_current()
		#
		#Eternity.save()
		#
		## TODO: send player to "quest finished" scene
		#get_tree().change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")
		#
		#return
	#
	#Eternity.save()
	#
	#get_tree().change_scene_to_file("res://Engine/Scenes/StageSelect/StageSelect.tscn")


static func get_instance() -> StageScene:
	return _instance
