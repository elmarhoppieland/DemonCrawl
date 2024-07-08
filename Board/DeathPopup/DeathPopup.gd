extends Node
class_name DeathPopup

# ==============================================================================
static var _instance: DeathPopup
# ==============================================================================
@onready var death_message_label: Label = %DeathMessageLabel
@onready var red_overlay: ColorRect = %RedOverlay
@onready var menu_button_canvas: CanvasLayer = %MenuButtonCanvas
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _enter_tree() -> void:
	_instance = self
	
	EffectManager.connect_effect(func lose(source: Object):
		_instance.death_message_label.text = DeathPopup.get_death_message(source)
		_instance.animation_player.play("show")
	)


func _process(_delta: float) -> void:
	if red_overlay.visible:
		red_overlay.position = StageCamera.get_center() - red_overlay.size / 2


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func return_to_menu() -> void:
	red_overlay.hide()
	Quest.stages.clear()
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


static func get_death_message(source: Object) -> String:
	if source.has_method("get_death_message"):
		var messages: PackedStringArray = source.get_death_message()
		return messages[RNG.randi() % messages.size()]
	
	return TranslationServer.tr("DEATH_MESSAGE_GENERIC")


func _on_view_board_button_pressed() -> void:
	animation_player.play("hide")
	animation_player.queue("show_menu_button")


func _on_restart_button_pressed() -> void:
	animation_player.play("hide", -1, INF)
	red_overlay.hide()
	Quest.stages.clear()
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _on_return_to_menu_button_pressed() -> void:
	animation_player.play("hide", -1, INF)
	return_to_menu()


func _on_menu_button_pressed() -> void:
	menu_button_canvas.hide()
	return_to_menu()
