extends HBoxContainer
class_name StageDetails

# ==============================================================================
static var _black_texture: ImageTexture
# ==============================================================================
@export var stage_name := ""
@export var min_power := 1
@export var max_power := 1
@export var monster_count := 0
@export var stage_size := 0
@export var locked := false
# ==============================================================================
var hovered := false
# ==============================================================================
@onready var _stage_texture: TextureRect = %StageTexture
@onready var _name_label: Label = %NameLabel
@onready var _unknown_info: Control = %UnknownInfo
@onready var _info_container: HBoxContainer = %InfoContainer
@onready var _power_label: Label = %PowerLabel
@onready var _lore_label: Label = %LoreLabel
@onready var _monster_label: Label = %MonsterLabel
@onready var _size_label: Label = %SizeLabel
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
# ==============================================================================
signal interacted()
# ==============================================================================

func _process(_delta: float) -> void:
	if hovered and Input.is_action_just_pressed("interact"):
		interacted.emit()


## Updates the stage_name's details. Call this after changing any of this node's properties
## to visually show the changes.
func update() -> void:
	if locked:
		_unknown_info.show()
		_info_container.hide()
		if not _black_texture:
			_black_texture = ImageTexture.create_from_image(Image.create(64, 64, false, Image.FORMAT_L8))
		_stage_texture.texture = _black_texture
		return
	
	var image: Image = load("res://Assets/skins".path_join(stage_name).path_join("bg.png")).get_image()
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	_stage_texture.texture = ImageTexture.create_from_image(image)
	
	_name_label.text = stage_name.capitalize()
	_lore_label.text = "The journey begins here."
	
	_power_label.text = str(min_power) + "-" + str(max_power)
	_monster_label.text = str(monster_count)
	_size_label.text = str(stage_size)
	
	_unknown_info.hide()
	_info_container.show()


func load_stage(stage: Stage) -> void:
	stage_name = stage.name
	stage_size = stage.size.x * stage.size.y
	monster_count = stage.monsters
	min_power = stage.min_power
	max_power = stage.max_power
	
	locked = stage.locked
	
	update()


func _on_texture_container_mouse_entered() -> void:
	_animation_player.play("hover")
	hovered = true


func _on_texture_container_mouse_exited() -> void:
	_animation_player.play_backwards("hover")
	hovered = false
