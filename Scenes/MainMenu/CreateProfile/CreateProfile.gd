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
			#var tween := create_tween()
			#tween.tween_property(background_anchor, "scale:y", background_anchor.scale.y, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			#tween.parallel().tween_property(contents_anchor, "position:y", contents_anchor.position.y, 0.5).from(contents_anchor.position.y + 8)
			#tween.parallel().tween_property(contents_anchor, "modulate:a", 1.0, 0.5).from(0.0)
	)


func _on_confirm_button_pressed() -> void:
	animation_player.play("popup_hide")
	#contents_anchor.hide()
	#var tween := create_tween()
	#tween.tween_property(background_anchor, "scale:y", 0.0, 0.5).from(background_anchor.scale.y).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	await animation_player.animation_finished
	
	#hide()
	#contents_anchor.show() # doesn't actually show but makes this scene reusable
	
	ProfileList.selected_profile = input.text.trim_suffix("_")
	var path := "user://saves/".path_join(ProfileList.selected_profile + ".ini")
	SavesManager.save_path = path
	SavesManager.save()
	confirmed.emit(ProfileList.selected_profile)
