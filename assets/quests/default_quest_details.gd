@tool
extends VBoxContainer
class_name DefaultQuestDetails

# ==============================================================================
@export var quest_name := "" :
	set(value):
		quest_name = value
		
		if not is_node_ready():
			await ready
		
		_name_label.text = value
@export_multiline var quest_lore := "" :
	set(value):
		quest_lore = value
		
		if not is_node_ready():
			await ready
		
		_lore_label.text = value
# ==============================================================================
@onready var _name_label: Label = %NameLabel
@onready var _lore_label: Label = %LoreLabel
# ==============================================================================
