@tool
extends Resource
class_name EmblemData

## Stores data about an [Emblem].

# ==============================================================================
@export var name := "" ## The name of the emblem.
@export var icon: Texture2D ## The icon of the emblem.
@export var level := 1 ## The level of the emblem.
@export var artifact_cost := 10 ## The number of artifacts this emblem costs, per slot.
@export var token_cost := 10 ## The number of tokens this emblem costs.

## The lore of this emblem, to be displayed in quotes at the top of the emblem's
## description.
@export_multiline var lore := ""
## The effects of this emblem. Each will be displayed as a bullet point in the
## emblem's description.
@export_multiline var effects: Array[String] = []

## The emblem's script. This script should extend [Emblem], and will be used to
## determine the emblem's effects.
@export var emblem_script: Script
# ==============================================================================

## Returns this emblem's full description, constructed from this emblem's properties.
func get_description() -> String:
	return "%s\n\"%s\"\n• %s\n• %s" % [
		tr("beyond.emblem.description.level").format({ "level": level }),
		tr(lore),
		tr("beyond.emblem.description.cost").format({
			"tokens": token_cost,
			"artifacts": artifact_cost
		}),
		"\n• ".join(effects.map(tr))
	]


## Creates a new [Emblem] instance from this [EmblemData].
func create() -> Emblem:
	return emblem_script.new(self)
