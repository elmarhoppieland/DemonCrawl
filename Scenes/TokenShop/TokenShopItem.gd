extends MarginContainer
class_name TokenShopItem

# ==============================================================================
@export var icon: Texture2D :
	set(value):
		icon = value
		if not icon_rect:
			await ready
		icon_rect.texture = value
@export var item_name := "" :
	set(value):
		item_name = value
		if not name_label:
			await ready
		name_label.text = value
@export var cost := 0 :
	set(value):
		cost = value
		if not cost_label:
			await ready
		cost_label.text = str(value)
@export_multiline var description := "" :
	set(value):
		description = value
		if not tooltip_grabber:
			await ready
		tooltip_grabber.text = value
	get:
		if not tooltip_grabber:
			return description
		return tooltip_grabber.text
# ==============================================================================
var locked := false
var is_purchased := false
var hovered := false
# ==============================================================================
@onready var icon_rect: TextureRect = %IconRect
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal purchased()
# ==============================================================================

func lock() -> void:
	locked = true
	if not animation_player:
		await ready
	animation_player.play("lock")


func unlock() -> void:
	locked = false
	if not animation_player:
		await ready
	animation_player.play("unlock")


func purchase() -> void:
	is_purchased = true
	purchased.emit()
	
	if not animation_player:
		await ready
	if hovered:
		animation_player.play("hover", -1, -INF, true)
		await animation_player.animation_finished
		hovered = false
	animation_player.play("purchase")


static func create() -> TokenShopItem:
	return ResourceLoader.load("res://Scenes/TokenShop/TokenShopItem.tscn").instantiate()


func _on_icon_mouse_entered() -> void:
	if not locked and not is_purchased:
		hovered = true
		animation_player.play("hover")


func _on_icon_mouse_exited() -> void:
	hovered = false
	if not locked and not is_purchased:
		animation_player.play_backwards("hover")


func _on_tooltip_grabber_interacted() -> void:
	if not locked and not is_purchased:
		purchase()
