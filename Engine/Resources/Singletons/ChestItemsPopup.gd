@tool
extends Control
class_name ChestItemsPopup

# ==============================================================================
const ITEM_STRING_TABLE := "res://Assets/StringTables/Chest/Item.tres"
const OMEN_STRING_TABLE := "res://Assets/StringTables/Chest/Omen.tres"
# ==============================================================================
@export var rewards: Array[Collectible] = [] :
	set(value):
		rewards = value
		if not is_node_ready():
			await ready
		
		var has_omen := false
		for i in maxi(value.size(), _rewards_container.get_child_count()):
			var frame: Frame
			if i < _rewards_container.get_child_count():
				frame = _rewards_container.get_child(i)
			else:
				frame = Frame.create(CollectibleDisplay.create())
				frame.show_focus = false
				_rewards_container.add_child(frame)
			
			if i < value.size():
				var reward := value[i]
				
				if reward is OmenItem:
					has_omen = true
				
				var display: CollectibleDisplay = frame.get_content()
				if display.collectible != reward:
					if display.collectible and display.is_ancestor_of(display.collectible):
						display.collectible.queue_free()
					
					display.collectible = reward
					if not reward.is_inside_tree():
						display.add_child(reward)
			else:
				frame.queue_free()
		
		if has_omen:
			_string_table_label.table = load(OMEN_STRING_TABLE)
		else:
			_string_table_label.table = load(ITEM_STRING_TABLE)
		
		_string_table_label.generate()
# ==============================================================================
@onready var _rewards_container: HBoxContainer = %RewardsContainer
@onready var _string_table_label: StringTableLabel = %StringTableLabel
# ==============================================================================
