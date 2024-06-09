@tool
extends AtlasTexture
class_name Icon

# ==============================================================================
@export var name := "" :
	set(value):
		name = value
		
		var source_dict: Dictionary
		match name.get_base_dir():
			"":
				source_dict = AssetManager.ICONS
				atlas = preload("res://Assets/sprites/icons.png")
			"mastery":
				source_dict = AssetManager.MASTERIES
				atlas = preload("res://Assets/sprites/Masteries.png")
		
		region = source_dict.get(name, Rect2())
# ==============================================================================

func _init() -> void:
	atlas = preload("res://Assets/sprites/icons.png")
