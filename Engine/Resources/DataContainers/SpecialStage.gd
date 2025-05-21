extends Stage
class_name SpecialStage

## A stage that gives the player rewards in return for coins.

# ==============================================================================
enum Type {
	ITEM_SHOP,
	BAZAAR,
	CHAOS_FONT,
	ALTAR,
	RITE_OF_PASSAGE,
	LIBRARY,
	WAYGATE,
	STARPOND,
	GUILD,
	LIGHTHOUSE,
	SMITHY,
	ACADEMY,
	WORKSHOP,
	ITEM_TREE
}
# ==============================================================================
var type := Type.ITEM_SHOP
var bg: Texture2D
var icon: Texture2D
var icon_small: Texture2D

var dest_scene: PackedScene
# ==============================================================================

func create_big_icon() -> ImageTexture:
	if icon:
		return icon
	
	var image: Image
	image = bg.get_image()
	
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	
	return ImageTexture.create_from_image(image)


func get_theme() -> Theme:
	return null
