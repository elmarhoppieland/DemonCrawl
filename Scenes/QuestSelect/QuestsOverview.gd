extends VBoxContainer
class_name QuestsOverview

# ==============================================================================
static var _difficulty_paths_cache := PackedStringArray() :
	get:
		if _difficulty_paths_cache.is_empty():
			const DIR := "res://Assets/quests/difficulties/"
			
			for file in DirAccess.get_files_at(DIR):
				_difficulty_paths_cache.append(DIR.path_join(file))
		
		return _difficulty_paths_cache

static var selected_difficulty: DifficultyFile :
	get:
		if not selected_difficulty:
			selected_difficulty = DifficultyFile.new()
			selected_difficulty.load(selected_difficulty_path)
		return selected_difficulty
static var selected_difficulty_path: String = SavesManager.get_value("selected_difficulty_path", QuestsOverview, _difficulty_paths_cache[0]) :
	set(value):
		var different := value != selected_difficulty_path
		selected_difficulty_path = value
		if different:
			selected_difficulty = DifficultyFile.new()
			selected_difficulty.load(value)

static var selected_quest_idx: int = SavesManager.get_value("selected_quest_idx", QuestsOverview, 0) :
	set(value):
		var different := value != selected_quest_idx
		selected_quest_idx = value
		if different:
			selected_quest = null
static var selected_quest: QuestFile :
	get:
		if not selected_quest:
			selected_quest = QuestFile.new()
			selected_quest.load(selected_difficulty.get_quests()[selected_quest_idx])
		return selected_quest

static var player_data: Dictionary = SavesManager.get_value("player_data", QuestsOverview, {
	"DIFFICULTY_CASUAL": [{"completions": 0, "best": 0}, {"completions": 0, "best": 0}],
	"DIFFICULTY_NORMAL": [{"completions": 0, "best": 0}, {"completions": 0, "best": 0}]
})
# ==============================================================================
var quest_icons: Array[TextureRect] = []
# ==============================================================================
@onready var quest_icons_container: HBoxContainer = %QuestIconsContainer
@onready var difficulty_select: TextureRect = %DifficultySelect
@onready var difficulty_select_icon: Icon = difficulty_select.texture
@onready var difficulty_select_tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var player_data_label: Label = %PlayerDataLabel
# ==============================================================================
signal quest_selected(quest: QuestFile, difficulty: DifficultyFile)
# ==============================================================================

func _ready() -> void:
	redraw_quests()
	
	Debug.push_debug(get_tree().current_scene, "Selected Quest Index", selected_quest_idx)


func redraw_quests() -> void:
	for icon in quest_icons:
		icon.queue_free()
	
	quest_icons.clear()
	
	difficulty_select_icon.name = selected_difficulty.get_icon_path()
	difficulty_select_tooltip_grabber.text = tr(selected_difficulty.get_name())
	
	for i in selected_difficulty.get_quests().size():
		var quest := QuestFile.new()
		quest.load(selected_difficulty.get_quests()[i])
		add_quest(quest, i == selected_quest_idx)


func add_quest(quest: QuestFile, main: bool = false) -> void:
	var icon := TextureRect.new()
	icon.name = quest.get_name()
	
	var index := quest_icons.size()
	var locked := not QuestsOverview.is_quest_unlocked(index)
	quest.set_meta("locked", locked)
	#quest.set_meta("index", index)
	
	if locked:
		icon.texture = AssetManager.get_icon("icon_locked")
	else:
		icon.texture = quest.create_icon()
	
	var focus_grabber := FocusGrabber.new()
	focus_grabber.main = main
	icon.add_child(focus_grabber)
	
	focus_grabber.interacted.connect(func():
		QuestsOverview.selected_quest_idx = index
		Debug.push_debug(get_tree().current_scene, "Selected Quest Index", QuestsOverview.selected_quest_idx)
		
		var completions: int = 0 if locked else QuestsOverview.get_current_player_data()[index].completions
		var best: int = 0 if locked else QuestsOverview.get_current_player_data()[index].best
		player_data_label.text = ("%s: x%d\n%s: %s" % [
			tr("QUEST_COMPLETIONS"),
			completions,
			tr("QUEST_BEST"),
			best if completions > 0 else "-"
		])
		
		quest_selected.emit(quest, QuestsOverview.selected_difficulty)
	)
	
	quest_icons_container.add_child(icon)
	
	quest_icons.append(icon)


func change_difficulty(direction: int) -> void:
	var idx := _difficulty_paths_cache.find(selected_difficulty_path)
	
	while true:
		if idx < 0:
			Debug.log_warning("Could not find the selected difficulty (%s) in the cached difficulties. Selecting the first difficulty..." % selected_difficulty_path)
			idx = 0
		else:
			idx = wrapi(idx + direction, 0, _difficulty_paths_cache.size())
		
		selected_difficulty_path = _difficulty_paths_cache[idx]
		
		if selected_difficulty.is_unlocked():
			break
	
	redraw_quests()


func _on_difficulty_select_interacted() -> void:
	change_difficulty(+1)


func _on_difficulty_select_second_interacted() -> void:
	change_difficulty(-1)


static func get_current_player_data() -> Array[Dictionary]:
	var current_data: Array = player_data[selected_difficulty.get_name()]
	if current_data.size() < selected_difficulty.get_quests().size():
		for i in range(current_data.size(), selected_difficulty.get_quests().size()):
			current_data.append({
				"completions": 0,
				"best": 0
			})
	
	var data: Array[Dictionary] = []
	data.assign(current_data)
	return data


static func is_quest_unlocked(quest_index: int) -> bool:
	if quest_index < selected_difficulty.get_initial_unlocks():
		return true
	
	if selected_difficulty.requires_token_shop_purchase():
		return TokenShop.is_item_purchased("TOKEN_SHOP_UPGRADE_QUEST_" + str(quest_index + 1))
	else:
		return PlayerFlags.has_flag("%s/%s" % [
			selected_difficulty.get_name(),
			selected_difficulty.open_quests()[quest_index - 1].get_name()
		])
