@tool
extends MarginContainer
class_name ItemIcon

# ==============================================================================
@export var data: ItemData :
	set(value):
		data = value
		
		if not is_node_ready():
			await ready
		
		mana_bar.visible = data and data.mana
		
		if not value:
			bg_color_rect.color = Color.TRANSPARENT
			texture_rect.texture.atlas = null
			texture_rect.texture.region = Rect2()
			return
		
		texture_rect.texture.atlas = data.atlas
		texture_rect.texture.region = data.atlas_region
		
		if data.mana:
			mana_bar.max_value = data.mana
		
		bg_color_rect.color = data.get_color()
@export var current_mana := 0 :
	set(value):
		current_mana = value
		
		if not is_node_ready():
			await ready
		
		mana_bar.value = value
		
		if _tween:
			_tween.kill()
		
		if data and data.mana and value >= data.mana:
			const GLOW_DURATION := 0.4
			const GLOW_WAIT := 0.4
			
			_tween = create_tween().set_loops()
			_tween.tween_method(set_glow, 0.0, 1.0, GLOW_DURATION)
			_tween.tween_method(set_glow, 1.0, 0.0, GLOW_DURATION)
			_tween.tween_interval(GLOW_WAIT)
		else:
			set_glow(0)
# ==============================================================================
var _tween: Tween
# ==============================================================================
@onready var bg_color_rect: ColorRect = %BGColorRect
@onready var texture_rect: TextureRect = %TextureRect
@onready var mana_bar: ProgressBar = %ManaBar
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal interacted()
signal second_interacted()
# ==============================================================================

func set_glow(value: float) -> void:
	(texture_rect.material as ShaderMaterial).set_shader_parameter("glow", value)


static func create(_data: ItemData) -> ItemIcon:
	var instance: ItemIcon = load("res://engine/resources/scenes/item_icon.tscn").instantiate()
	instance.data = _data
	return instance


func _on_tooltip_grabber_about_to_show() -> void:
	if not data:
		tooltip_grabber.text = ""
		return
	
	tooltip_grabber.text = data.name
	if data.mana:
		tooltip_grabber.subtext = "[%d/%d Mana]\n" % [current_mana, data.mana] + data.description
	else:
		tooltip_grabber.subtext = data.description


func _on_tooltip_grabber_interacted() -> void:
	interacted.emit()


func _on_tooltip_grabber_second_interacted() -> void:
	second_interacted.emit()
