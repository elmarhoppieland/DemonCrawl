@tool
extends SpecialStage
class_name Bazaar

# ==============================================================================

func _get_name_id() -> String:
	return "stage.special.bazaar"


func _get_bg() -> Texture2D:
	return preload("res://assets/backgrounds/bazaar.png")


func _get_large_icon() -> Texture2D:
	return preload("res://assets/special_stages/bazaar/bazaar.png")


func _get_small_icon() -> Texture2D:
	return ImageTexture.create_from_image(_shrink(get_large_icon().get_image(), 16))


func _create_instance() -> BazaarInstance:
	return BazaarInstance.new()
