@tool
extends Resource
class_name GlintData

# ==============================================================================
@export var name := "" ## The name of this glint.
@export var icon: Texture2D = null ## The icon of this glint.

## A list of this glint's effects. Each will be displayed as a bullet point in
## the glint's description.
@export_multiline var effects: Array[String] = []

## The glint's [Script]. This script should extend [Glint], and will be used to
## determine the glint's effects.
@export var glint_script: Script = null
# ==============================================================================

## Returns this glint's full description, constructed from this glint's [member effects].
func get_description() -> String:
	return "• " + "\n• ".join(effects.map(tr))


## Creates an instance of this glint.
func create() -> Glint:
	return glint_script.new()
