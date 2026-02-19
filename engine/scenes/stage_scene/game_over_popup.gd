extends CanvasLayer
class_name GameOverPopup

# ==============================================================================
const GAME_OVER_AUDIO: AudioStream = preload("res://assets/music/game_over.ogg")
# ==============================================================================
@export var view_button: DCButton
@export var restart_button: DCButton
@export var cause: String = ""
# ==============================================================================
var quest: Quest
# ==============================================================================
@onready var _cause_label: Label = %CauseLabel
@onready var _animation_player = %AnimationPlayer
# ==============================================================================

func popup() -> void:
	show()
	
	if not quest.can_restart():
		restart_button.queue_free()
	
	_cause_label.text = load("res://assets/string_tables/game_over.tres").pick_random().format({ "cause": cause.to_upper() })
	
	AudioBus.stop_ambience()
	AudioBus.play_music(GAME_OVER_AUDIO)
	
	_animation_player.play("popup_show")
	
	await _animation_player.animation_finished


func _on_view_board_pressed() -> void:
	_animation_player.play("popup_hide")
	
	await _animation_player.animation_finished
	
	quest.get_current_stage().get_scene().show_menu_return()
	
	hide()
	queue_free()


func _on_restart_pressed() -> void:
	quest.restart()
	
	get_tree().change_scene_to_file("res://engine/scenes/stage_select/stage_select.tscn")
	
	quest.queue_free()
	queue_free()


func _on_return_to_menu_pressed() -> void:
	_animation_player.play("popup_hide")
	
	await _animation_player.animation_finished
	
	hide()
	
	get_tree().change_scene_to_file("res://engine/scenes/main_menu/main_menu.tscn")
	
	quest.queue_free()
	queue_free()
