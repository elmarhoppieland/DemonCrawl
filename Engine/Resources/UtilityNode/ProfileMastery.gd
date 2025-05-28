@tool
extends TextureRect
class_name ProfileMastery

# ==============================================================================
static var icon: Icon
	#get:
		#if not Mastery.selected:
			#return AssetManager.get_icon("mastery/none")
		#return Mastery.selected.icon
# ==============================================================================

func _enter_tree() -> void:
	texture = icon


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var tooltip_grabber := TooltipGrabber.new()
	if Codex.selected_mastery:
		var mastery_name := tr("MASTERY_" + Quest.get_current().get_mastery()._get_identifier())
		tooltip_grabber.text = tr(mastery_name)
		tooltip_grabber.text += " " + RomanNumeral.convert_to_roman(TokenShop.get_purchased_level(Codex.selected_mastery._token_shop_items.get(Codex.selected_mastery.get_script(), null))) # TODO: properly get the purchased level
		
		tooltip_grabber.subtext = "• " + "\n• ".join(Quest.get_current().get_mastery().get_description())
	else:
		tooltip_grabber.text = tr("MASTERY_NONE")
	
	add_child(tooltip_grabber)
