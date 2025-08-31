extends TextureNode
class_name AnnotatedTextureNode

## A [TextureNode] that holds annotation text.

# ==============================================================================

## Returns this texture's annotation text.
func get_annotation_text() -> String:
	var override := _get_annotation_text()
	if not override.is_empty():
		return override
	
	var title := get_annotation_title()
	var subtext := get_annotation_subtext()
	if subtext.is_empty():
		return title
	if title.is_empty():
		return "[color=gray]" + subtext + "[/color]"
	
	return title + "\n[color=gray]" + subtext + "[/color]"


## Virtual method to override the return value of [method get_annotation_text].
## Return an empty [String] to fallback to the default (joining [method get_annotation_title]
## and [method get_annotation_subtext]). If a non-empty [String] is returned,
## [method get_annotation_title] and [method get_annotation_subtext] are not called.
func _get_annotation_text() -> String:
	return ""


## Returns this texture's annotation title, to be displayed on top in the annotation text.
func get_annotation_title() -> String:
	return _get_annotation_title()


## Virtual method to override the return value of [method get_annotation_title].
func _get_annotation_title() -> String:
	return ""


## Returns this texture's annotation subtext, to be displayed in gray below the
## title in the annotation text.
func get_annotation_subtext() -> String:
	return _get_annotation_subtext()


## Virtual method to override the return value of [method get_annotation_subtext].
func _get_annotation_subtext() -> String:
	return ""


## Returns whether this [AnnotatedTexture] has text to display.
func has_annotation_text() -> bool:
	return _has_annotation_text()


## Virtual method to override the return value of [method has_annotation_text].
func _has_annotation_text() -> bool:
	return true
