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
	
	add_none_mastery()
	
	const DIR := "res://Assets/scripts/masteries/"
	for file in DirAccess.get_files_at(DIR):
		var path := DIR.path_join(file)
		add_mastery_from_script(path)


func add_none_mastery() -> void:
	add_mastery("MASTERY_NONE", IconManager.get_icon_data("mastery/none").create_texture(), "")


func add_mastery_from_script(script_path: String) -> void:
	var script = ResourceLoader.load(script_path)
	if not script is Script:
		Debug.log_error("The file at '%s' was attempted to be loaded as a mastery script, but it is either not a Script or not loadable." % script_path)
		return
	
	var mastery: Mastery = script.new()
	mastery.level = TokenShop.get_purchased_level("MASTERY_" + mastery._get_identifier())
	
	add_mastery("MASTERY_" + mastery._get_identifier(), mastery.icon, script_path, mastery.get_description())


func add_mastery(mastery_name: String, icon: Texture2D, identifier: String, description: PackedStringArray = [], unlock_text: String = "") -> void:
	const LOCK_ALPHA := 0.5
	
	var locked := description.is_empty() and not unlock_text.is_empty()
	
	var texture_rect := TextureRect.new()
	texture_rect.texture = icon
	
	if not locked:
		var grabber := CheckmarkGrabber.new()
		#grabber.main = Mastery.selected_path == identifier
		texture_rect.add_child(grabber)
		
		#grabber.interacted.connect(func():
			#Mastery.selected_path = identifier
		#)
	
	var tooltip_grabber := TooltipGrabber.new()
	tooltip_grabber.text = tr(mastery_name)
	
	if locked:
		tooltip_grabber.text += " I"
		tooltip_grabber.subtext = "(" + tr(unlock_text) + ")"
	elif not unlock_text.is_empty():
		tooltip_grabber.text += " " + RomanNumeral.convert_to_roman(description.size())
		tooltip_grabber.subtext = "• " + "\n• ".join(description)
	
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
	lock.texture = IconManager.get_icon_data("icons/icon_locked_flat").create_texture()
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
