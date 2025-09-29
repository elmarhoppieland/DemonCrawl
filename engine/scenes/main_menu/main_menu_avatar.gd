@tool # parent class needs @tool
extends Avatar

# ==============================================================================
var mouse_is_inside := false
var tween: Tween
# ==============================================================================
@onready var profile_list_container: VBoxContainer = %ProfileListContainer
# ==============================================================================

func _ready() -> void:
	mouse_entered.connect(func():
		get_child(0).show()
		mouse_is_inside = true
	)
	mouse_exited.connect(func():
		get_child(0).hide()
		mouse_is_inside = false
	)
	
	profile_list_container.hide()


func _process(_delta: float) -> void:
	if tween:
		return
	
	if mouse_is_inside and Input.is_action_just_pressed("interact"):
		if profile_list_container.visible:
			tween = create_tween()
			tween.tween_property(profile_list_container, "position:x", -profile_list_container.size.x, 0.2)
			await tween.finished
			tween = null
			
			profile_list_container.hide()
		else:
			profile_list_container.show()
			
			tween = create_tween()
			tween.tween_property(profile_list_container, "position:x", 4.0, 0.2)
			await tween.finished
			tween = null
