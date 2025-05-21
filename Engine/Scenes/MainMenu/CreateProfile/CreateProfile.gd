extends CanvasLayer
class_name CreateProfile

# ==============================================================================
@onready var background_anchor: Node2D = %BackgroundAnchor
@onready var contents_anchor: Node2D = %ContentsAnchor
@onready var input: DCLineEdit = %Input
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal confirmed()
# ==============================================================================

func _ready() -> void:
	visibility_changed.connect(func():
		if visible:
			animation_player.play("popup_show")
	)


func _on_confirm_button_pressed() -> void:
	animation_player.play("popup_hide")
	
	await animation_player.animation_finished
	
	ProfileList.selected_profile = input.text.trim_suffix("_")
	Eternity.path = "user://saves/".path_join(ProfileList.selected_profile + ".ini")
	Eternity.save()
	confirmed.emit(ProfileList.selected_profile)
