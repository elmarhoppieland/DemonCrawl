extends HBoxContainer
class_name MainMenuProfile

# ==============================================================================
@export var profile_name := "" :
	set(value):
		profile_name = value
		if not name_label:
			await ready
		name_label.text = value
@export var avatar_atlas_position := Vector2i.ZERO :
	set(value):
		avatar_atlas_position = value
		if not avatar:
			await ready
		avatar.texture = Avatar.atlas.duplicate()
		avatar.texture.region.position = Vector2(value) * Avatar.atlas.region.size
@export var level := 0 :
	set(value):
		level = value
		if not level_label:
			await ready
		if value < 0:
			level_label.text = ""
			return
		level_label.text = (tr("LEVEL") if "%" in tr("LEVEL") else "Lv%d") % (value + 1)
# ==============================================================================
var mouse_is_inside := false
# ==============================================================================
@onready var avatar: TextureRect = %Avatar
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
# ==============================================================================
signal selected()
# ==============================================================================

func _ready() -> void:
	mouse_entered.connect(func(): mouse_is_inside = true)
	mouse_exited.connect(func(): mouse_is_inside = false)


func _process(_delta: float) -> void:
	if mouse_is_inside and Input.is_action_just_pressed("interact"):
		selected.emit()


static func create(_profile_name: String = "", _avatar_atlas_position: Vector2i = Vector2i.ZERO, _level: int = 0) -> MainMenuProfile:
	var profile: MainMenuProfile = ResourceLoader.load("res://Scenes/MainMenu/Profile.tscn").instantiate()
	profile.profile_name = _profile_name
	profile.avatar_atlas_position = _avatar_atlas_position
	profile.level = _level
	return profile
