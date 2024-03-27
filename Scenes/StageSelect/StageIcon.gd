extends MarginContainer
class_name StageIcon

## An icon on the [StagesOverview] for a single stage.

# ==============================================================================
var stage: Stage

var _hovered := false
# ==============================================================================
@onready var _icon: TextureRect = %Icon
# ==============================================================================
signal selected()
# ==============================================================================

func _ready() -> void:
	_icon.texture = StageIcon.create_texture(stage.name)


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
	var image: Image = load("res://Assets/skins".path_join(stage_name).path_join("bg.png")).get_image()
	image.convert(Image.FORMAT_RGBA8)
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(16, 16)
	
	for px: Vector2i in [Vector2i(0, 0), Vector2i(15, 0), Vector2i(0, 15), Vector2i(15, 15)]:
		image.set_pixelv(px, Color.TRANSPARENT)
	
	var texture := ImageTexture.create_from_image(image)
	return texture
