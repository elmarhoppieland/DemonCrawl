@tool
extends Label

# ==============================================================================
@export var cell_value := 0 :
	set(value):
		cell_value = maxi(value, 0)
		
		label_settings.outline_color = get_theme_color("number_%s" % (str(cell_value) if cell_value < 10 else "other") , "Cell")
		
		if cell_value:
			text = str(cell_value)
		else:
			text = ""
@export var object_textue: TextureRect
# ==============================================================================

func _ready() -> void:
	theme_changed.connect(func(): cell_value = cell_value)


func _process(_delta: float) -> void:
	if _has_object():
		hide()
	else:
		show()


func _has_object() -> bool:
	if not Engine.is_editor_hint() and not owner.revealed:
		return true
	
	if not object_textue:
		return false
	if not object_textue.texture:
		return false
	if not object_textue.visible:
		return false
	if object_textue.texture is AtlasTexture and not object_textue.texture.atlas:
		return false
	
	return true
