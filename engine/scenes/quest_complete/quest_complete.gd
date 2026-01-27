@tool
extends Control
class_name QuestComplete

# ==============================================================================
@onready var _summary_label = %"SummaryLabel"
@onready var _score_label = %"ScoreLabel"
@onready var _monster_sprite = %"MonsterSprite"
@onready var _monster_taunt = %"MonsterText"
@onready var _animation_player = %"QuestCompleteAP"
# ==============================================================================

func _ready() -> void:
	var quest := Quest.get_current()
	var summary_values := {
		"quest_name": tr(quest.source_file.name).to_upper(),
		"color": quest.source_difficulty.color.to_html(false),
		"difficulty_name": tr(quest.source_difficulty.name).to_upper()
	}
	_summary_label.text = tr("quest-finished.summary").format(summary_values)
	_score_label.text = tr("quest-finished.score").format({"score": quest.get_attributes().score})
	
	var stages: Array[StageBase] = quest.get_stages().filter(func (stage: StageBase) -> bool:
		return not stage.is_special()
	)
	var random_base := stages[randi() % len(stages)]
	_monster_sprite.texture = random_base.get_theme().get_icon("monster", "Cell").duplicate()
	_monster_taunt.text = load("res://assets/string_tables/monster_taunts.tres").pick_random().format({"monster": random_base.generate_monster_name().to_upper()})
	_monster_taunt.visible_characters = 0
	
	_animation_player.play(&"quest_finished")


func animate_monster_taunt():
	_monster_taunt.create_tween().tween_property(_monster_taunt, "visible_characters", len(_monster_taunt.text), len(_monster_taunt.text) / 60.0)


func _on_done_pressed():
	Quest.get_current().finish()
