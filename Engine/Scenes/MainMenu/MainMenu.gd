extends Control
class_name MainMenu

# ==============================================================================
const ANIM_WAIT := 1.0
const LOGO_BASE_ANIM_DURATION := 0.5
const LOGO_TOP_ANIM_DURATION := 1.0
const TOTAL_ANIM_DURATION := ANIM_WAIT + LOGO_BASE_ANIM_DURATION + LOGO_TOP_ANIM_DURATION
# ==============================================================================
var tween: Tween
# ==============================================================================
@onready var button_bar: MarginContainer = %ButtonBar
@onready var copyright: RichTextLabel = %Copyright
@onready var external_buttons: HBoxContainer = %ExternalButtons
@onready var profile_select: Control = %ProfileSelect
@onready var bottom_right_buttons: HBoxContainer = %BottomRightButtons
@onready var create_profile: CreateProfile = %CreateProfile
# ==============================================================================

func _ready() -> void:
	button_bar.hide()
	copyright.hide()
	external_buttons.hide()
	profile_select.hide()
	bottom_right_buttons.hide()
	
	tween = create_tween()
	tween.tween_interval(TOTAL_ANIM_DURATION)
	await tween.finished
	
	#if not OS.is_debug_build() or not Input.is_key_pressed(KEY_ALT):
		#Eternity.save()
	
	if ProfileList.selected_profile.is_empty():
		create_profile.show()
		await create_profile.confirmed
	else:
		Eternity.path = "user://saves/".path_join(ProfileList.selected_profile + ".ini")
	
	button_bar.show()
	#copyright.show()
	external_buttons.show()
	profile_select.show()
	bottom_right_buttons.show()
	
	Toasts.add_debug_toast("Profile Loaded: %s" % ProfileList.selected_profile)
	
	Eternity.save("settings")


func _process(_delta: float) -> void:
	if tween and tween.is_running() and Input.is_action_just_pressed("interact"):
		tween.set_speed_scale(INF)
