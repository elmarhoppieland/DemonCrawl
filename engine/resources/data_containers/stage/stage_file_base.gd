@abstract
extends Resource
class_name StageFileBase

# ==============================================================================
var _theme_cache: Theme
# ==============================================================================

## Creates and returns a new [Theme] resource, with all relevant properties set
## to this [StageFile]'s theme. Caches the result, to be returned on future calls.
func create_theme() -> Theme:
	if _theme_cache:
		return _theme_cache
	
	_theme_cache = _create_theme()
	return _theme_cache


## Virtual method. Should return this stage's [Theme]. The result is cached, and
## will be reused for this stage file until [method clear_theme_cache] is called.
@abstract func _create_theme() -> Theme


## Clears the [Theme] cache for this stage file. Does [b]not[/b] reload the [Theme]
## everywhere, but the next call to [method create_theme] will create a new [Theme].
func clear_theme_cache() -> void:
	_theme_cache = null


## Returns the name of the stage. The returned [String] may be a translation [String].
func get_stage_name() -> String:
	return _get_name()


## Virtual method. Should return the stage's name. This may be a translation [String].
@abstract func _get_name() -> String


## Returns this stage's background texture.
func get_bg() -> Texture2D:
	return _get_bg()


## Virtual method. Should return this stage's background texture.
@abstract func _get_bg() -> Texture2D


## Returns the music that should play in this stage.
func get_music() -> AudioStream:
	return _get_music()


## Virtual method. Should return the music that should play in this stage.
@abstract func _get_music() -> AudioStream


## Returns the first part of the ambience that should play in this stage.
func get_ambience_a() -> AudioStream:
	return _get_ambience_a()


## Virtual method. Should return the first part of the ambience that should play
## in this stage.
@abstract func _get_ambience_a() -> AudioStream


## Returns the second part of the ambience that should play in this stage.
func get_ambience_b() -> AudioStream:
	return _get_ambience_b()


## Virtual method. Should return the second part of the ambience that should play
## in this stage.
@abstract func _get_ambience_b() -> AudioStream


## Returns a list of [Artifact]s that may spawn in this stage.
func get_artifacts() -> Array[StageFile]:
	return _get_artifacts()


## Virtual method. Should return a list of [Artifact]s that may spawn in this stage.
@abstract func _get_artifacts() -> Array[StageFile]
