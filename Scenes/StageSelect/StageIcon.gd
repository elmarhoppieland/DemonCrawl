extends MarginContainer
class_name StageIcon

## An icon on the [StagesOverview] for a single stage.

# ==============================================================================
const IMAGE_PATH := "res://Assets/skins/%s/bg.png"
# ==============================================================================
var stage: Stage :
	set(value):
		stage = value
		
		if null in [_icon, _lock, _checkmark]:
			await ready
		
		_lock.visible = stage.locked
		_checkmark.visible = stage.completed
		if stage.locked or stage.completed:
			_icon.modulate = Color.WHITE * 0.7
		else:
			_icon.modulate = Color.WHITE
		
		if "icon_small" in stage and stage.icon_small != null:
			_icon.texture = stage.icon_small
		elif "icon" in stage and stage.icon != null:
			_icon.texture = StageIcon.shrink_image(stage.icon.get_image())
		elif FileAccess.file_exists(IMAGE_PATH % stage.name):
			_icon.texture = StageIcon.create_texture(stage.name)
		else:
			_icon.texture = StageIcon.shrink_image(AssetManager.get_icon("icon_questionmark").get_image())
var show_icon := false :
	set(value):
		show_icon = value
		
		if null in [_icon, _lock, _shadow]:
			await ready
		
		_shadow.visible = show_icon
		_icon.visible = show_icon

var _hovered := false
# ==============================================================================
@onready var _icon: TextureRect = %Icon
@onready var _shadow: TextureRect = %Shadow
@onready var _lock: TextureRect = %Lock
@onready var _checkmark: TextureRect = %Checkmark
# ==============================================================================
signal selected()
# ==============================================================================

func _process(_delta: float) -> void:
	if _hovered and Input.is_action_just_pressed("interact"):
		select()


func select() -> void:
	selected.emit()
	Focus.move_to(self)


func _on_mouse_entered() -> void:
	_hovered = true


func _on_mouse_exited() -> void:
	_hovered = false


## Creates and returns the icon of the given [code]stage[/code]. The returned icon is a 16x16 texture,
## with the corner pixels removed.
static func create_texture(stage_name: String) -> ImageTexture:
	var image: Image = load(IMAGE_PATH % stage_name).get_image()
	return shrink_image(image)


static func shrink_image(image: Image) -> ImageTexture:
	image.convert(Image.FORMAT_RGBA8)
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(16, 16)
	
	for px: Vector2i in [Vector2i(0, 0), Vector2i(15, 0), Vector2i(0, 15), Vector2i(15, 15)]:
		image.set_pixelv(px, Color.TRANSPARENT)
	
	var texture := ImageTexture.create_from_image(image)
	return texture
