extends Control
class_name EditEquipment

# ==============================================================================
enum Page {
	NONE,
	MASTERIES,
	CHESTS,
	SIGILS
}
# ==============================================================================
var current_page := Page.NONE
# ==============================================================================
@onready var flow_container: HFlowContainer = %FlowContainer
# ==============================================================================
signal back_button_pressed()
# ==============================================================================

func _ready() -> void:
	pass


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()


func _on_masteries_button_interacted() -> void:
	if current_page == Page.MASTERIES:
		return
	current_page = Page.MASTERIES
	
	while flow_container.get_child_count() > 0:
		var child := flow_container.get_child(0)
		flow_container.remove_child(child)
		child.queue_free()
	
	add_mastery(null)
	
	for mastery in DemonCrawl.get_full_registry().masteries:
		var data := Mastery.MasteryData.new()
		data.mastery = mastery
		data.level = Codex.get_selectable_mastery_level(mastery)
		if data.level == 0:
			data.level = 1
		add_mastery(data)


func add_mastery(mastery: Mastery.MasteryData) -> void:
	const LOCK_ALPHA := 0.5
	
	var icon := mastery.create_temp().create_icon() if mastery else IconManager.get_icon_data("mastery/none").create_texture()
	
	var locked := (Codex.get_selectable_mastery_level(mastery) < mastery.level) if mastery else false
	
	var texture_rect := TextureRect.new()
	texture_rect.texture = icon
	
	if not locked:
		var grabber := CheckmarkGrabber.new()
		if mastery:
			grabber.main = Codex.selected_mastery.mastery == mastery.mastery
		else:
			grabber.main = Codex.selected_mastery == null
		texture_rect.add_child(grabber)
		
		grabber.interacted.connect(func():
			Codex.selected_mastery = mastery
		)
	
	var tooltip_grabber := TooltipGrabber.new()
	tooltip_grabber.text = mastery.create_temp().get_display_name() if mastery else "MASTERY_NONE"
	
	if locked:
		tooltip_grabber.subtext = "(" + mastery.create_temp().get_condition_text() + ")"
	else:
		var description := mastery.create_temp().get_description_text() if mastery else ""
		tooltip_grabber.subtext = description
	
	if not locked:
		texture_rect.add_child(tooltip_grabber)
		
		flow_container.add_child(texture_rect)
		return
	
	var margin := MarginContainer.new()
	margin.add_child(tooltip_grabber)
	margin.add_child(texture_rect)
	
	var color := ColorRect.new()
	color.color = Color(Color.BLACK, LOCK_ALPHA)
	margin.add_child(color)
	
	var lock := TextureRect.new()
	lock.texture = IconManager.get_icon_data("icons/locked_flat").create_texture()
	margin.add_child(lock)
	
	flow_container.add_child(margin)


func _on_chests_button_interacted() -> void:
	if current_page == Page.CHESTS:
		return
	current_page = Page.CHESTS


func _on_sigils_button_interacted() -> void:
	if current_page == Page.SIGILS:
		return
	current_page = Page.SIGILS
