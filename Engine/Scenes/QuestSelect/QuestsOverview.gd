extends VBoxContainer
class_name QuestsOverview

# ==============================================================================
#static var _difficulty_paths_cache := PackedStringArray() :
	#get:
		#if _difficulty_paths_cache.is_empty():
			#const DIR := "res://Assets/quests/difficulties/"
			#
			#for file in DirAccess.get_files_at(DIR):
				#_difficulty_paths_cache.append(DIR.path_join(file))
		#
		#return _difficulty_paths_cache

#static var selected_difficulty: Difficulty :
	#get:
		#if not selected_difficulty:
			#selected_difficulty = Difficulty.new()
			#selected_difficulty.load(selected_difficulty_path)
		#return selected_difficulty
# SavesManager.get_value("selected_difficulty_path", QuestsOverview, _difficulty_paths_cache[0])
#static var selected_difficulty_path: String = Eternal.create(_difficulty_paths_cache[0]) :
	#set(value):
		#var different := value != selected_difficulty_path
		#selected_difficulty_path = value
		#if different:
			#selected_difficulty = Difficulty.new()
			#selected_difficulty.load(value)

# SavesManager.get_value("selected_quest_idx", QuestsOverview, 0)
#static var selected_quest_idx: int = Eternal.create(0) :
	#set(value):
		#var different := value != selected_quest_idx
		#selected_quest_idx = value
		#if different:
			#selected_quest = null
#static var selected_quest: QuestFile :
	#get:
		#if not selected_quest:
			#selected_quest = QuestFile.new()
			#selected_quest.load(selected_difficulty.get_quests()[selected_quest_idx])
		#return selected_quest

# SavesManager.get_value("player_data", QuestsOverview, {...
static var player_data: Dictionary = {
	"DIFFICULTY_CASUAL": [{"completions": 0, "best": 0}, {"completions": 0, "best": 0}],
	"DIFFICULTY_NORMAL": [{"completions": 0, "best": 0}, {"completions": 0, "best": 0}]
}
# ==============================================================================
var quest_icons: Array[TextureRect] = []
# ==============================================================================
@onready var quest_icons_container: HBoxContainer = %QuestIconsContainer
@onready var difficulty_select: TextureRect = %DifficultySelect
@onready var difficulty_select_tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var player_data_label: Label = %PlayerDataLabel
# ==============================================================================
signal quest_selected(quest: QuestFile, difficulty: Difficulty)
# ==============================================================================

func _ready() -> void:
	redraw_quests()
	
	#Debug.push_debug(get_tree().current_scene, "Selected Quest Index", selected_quest_idx)


func redraw_quests() -> void:
	for icon in quest_icons:
		icon.queue_free()
	
	quest_icons.clear()
	
	difficulty_select.texture = QuestsManager.selected_difficulty.icon
	difficulty_select_tooltip_grabber.text = tr(QuestsManager.selected_difficulty.name)
	
	for quest in QuestsManager.selected_difficulty.quests:
		add_quest(quest)


func add_quest(quest: QuestFile) -> void:
	var icon := TextureRect.new()
	icon.name = quest.name
	
	var locked := not QuestsManager.is_quest_unlocked(quest)
	quest.set_meta("locked", locked)
	
	if locked:
		icon.texture = IconManager.get_icon_data("quest/locked").create_texture()
	else:
		icon.texture = quest.icon
	
	var focus_grabber := FocusGrabber.new()
	focus_grabber.main = quest == QuestsManager.selected_quest
	icon.add_child(focus_grabber)
	
	focus_grabber.interacted.connect(func() -> void:
		QuestsManager.selected_quest = quest
		
		var data := QuestsManager.get_completion_data(quest)
		var completions := 0 if locked else data.completion_count
		var best := 0 if locked else data.best_score
		player_data_label.text = ("%s: x%d\n%s: %s" % [
			tr("QUEST_COMPLETIONS"),
			completions,
			tr("QUEST_BEST"),
			str(best) if completions > 0 else "-"
		])
		
		quest_selected.emit(quest, QuestsManager.selected_difficulty)
	)
	
	quest_icons_container.add_child(icon)
	
	quest_icons.append(icon)


#func change_difficulty(direction: int) -> void:
	#var idx := _difficulty_paths_cache.find(selected_difficulty_path)
	#
	#while true:
		#if idx < 0:
			#Debug.log_warning("Could not find the selected difficulty (%s) in the cached difficulties. Selecting the first difficulty..." % selected_difficulty_path)
			#idx = 0
		#else:
			#idx = wrapi(idx + direction, 0, _difficulty_paths_cache.size())
		#
		#selected_difficulty_path = _difficulty_paths_cache[idx]
		#
		#if selected_difficulty.is_unlocked():
			#break
	#
	#redraw_quests()


func _on_difficulty_select_interacted() -> void:
	QuestsManager.change_difficulty(+1)


func _on_difficulty_select_second_interacted() -> void:
	QuestsManager.change_difficulty(-1)


static func get_current_player_data() -> Array[Dictionary]:
	var current_data: Array = player_data.get(QuestsManager.selected_difficulty.name, [])
	if current_data.size() < QuestsManager.selected_difficulty.quests.size():
		for i in range(current_data.size(), QuestsManager.selected_difficulty.quests.size()):
			current_data.append({
				"completions": 0,
				"best": 0
			})
	
	var data: Array[Dictionary] = []
	data.assign(current_data)
	return data

