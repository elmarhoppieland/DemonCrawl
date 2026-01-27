extends Control
class_name HighScorePopup

# ==============================================================================
const SCENE := "res://engine/resources/singletons/high_score_popup.tscn"
# ==============================================================================
@export var score := 0 :
	set(value):
		score = value
		if not is_node_ready():
			await ready
		_score_label.text = tr("popup.highscore.text").format({ "score": value })
# ==============================================================================
@onready var _score_label: Label = %ScoreLabel
# ==============================================================================

static func show_score(high_score: int) -> void:
	var instance: HighScorePopup = load(SCENE).instantiate()
	instance.score = high_score
	await DCPopup.popup_show_instance(instance)
	instance.queue_free()
