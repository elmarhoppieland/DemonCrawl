extends RefCounted
class_name Quest

## A single quest with any amount of stages.

# ==============================================================================
static var stages := PackedStringArray() ## The stages in the quest.
static var current_stage: Stage ## The stage that is currently being played, or an empty string if none is being played.
# ==============================================================================
