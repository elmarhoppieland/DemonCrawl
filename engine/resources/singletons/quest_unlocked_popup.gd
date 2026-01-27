extends Control
class_name QuestUnlockedPopup

# ==============================================================================
const SCENE := "res://engine/resources/singletons/quest_unlocked_popup.tscn"
# ==============================================================================
@export var locked := false
@export var quest := "" :
	set(value):
		quest = value
		if not is_node_ready():
			await ready
		_quest_label.text = tr("popup.new-quest." + ("locked" if locked else "unlocked")).format({"quest_name": tr(quest).to_upper()})
# ==============================================================================
@onready var _quest_label: Label = %QuestLabel
# ==============================================================================

static func show_quest_unlock(lock: bool, quest_id: String) -> void:
	var instance: QuestUnlockedPopup = load(SCENE).instantiate()
	instance.locked = lock
	instance.quest = quest_id
	await DCPopup.popup_show_instance(instance)
	instance.queue_free()
