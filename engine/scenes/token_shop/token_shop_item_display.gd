@tool
extends MarginContainer
class_name TokenShopItemDisplay

# ==============================================================================
const HOVER_ANIM_DURATION := 0.2
const HOVER_ANIM_BEGIN_OFFSET := Vector2(0, 4)
const ICON_COVERED_MODULATE := Color.DARK_GRAY
# ==============================================================================
@export var item: TokenShopItemBase = null :
	set(value):
		item = value
		update()
# ==============================================================================
#var locked := false :
	#set(value):
		#if locked == value:
			#return
		#
		#locked = value
		#
		#if not is_node_ready():
			#await ready
		#
		#if value:
			#is_purchased = false
			#
			#_icon_rect.modulate = Color.DARK_GRAY
			#_lock.show()
			#
			#if _hovered:
				#_hover_tween = create_tween().set_parallel()
				#_hover_tween.tween_property(_hover_anchor, "position", HOVER_ANIM_BEGIN_OFFSET, HOVER_ANIM_DURATION).from(Vector2.ZERO)
				#_hover_tween.tween_property(_hover_anchor, "modulate", Color.TRANSPARENT, HOVER_ANIM_DURATION).from(Color.WHITE)
		#else:
			#_icon_rect.modulate = Color.WHITE
			#_lock.hide()
#var is_purchased := false :
	#set(value):
		#if is_purchased == value:
			#return
		#
		#is_purchased = value
		#
		#if not is_node_ready():
			#await ready
		#
		#if value:
			#locked = false
			#
			#_icon_rect.modulate = Color.DARK_GRAY
			#_checkmark.show()
			#
			#if _hovered:
				#_hover_tween = create_tween().set_parallel()
				#_hover_tween.tween_property(_hover_anchor, "position", HOVER_ANIM_BEGIN_OFFSET, HOVER_ANIM_DURATION).from(Vector2.ZERO)
				#_hover_tween.tween_property(_hover_anchor, "modulate", Color.TRANSPARENT, HOVER_ANIM_DURATION).from(Color.WHITE)
		#else:
			#_icon_rect.modulate = Color.WHITE
			#_checkmark.hide()
# ==============================================================================
var _hovered := false
var _hover_tween: Tween = null :
	set(value):
		if _hover_tween:
			_hover_tween.kill()
		_hover_tween = value
# ==============================================================================
@onready var _icon_rect: TextureRect = %IconRect
@onready var _lock: TextureRect = %Lock
@onready var _checkmark: TextureRect = %Checkmark
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var _hover_anchor: Node2D = %HoverAnchor
@onready var _name_label: Label = %NameLabel
@onready var _cost_label: Label = %CostLabel
# ==============================================================================
signal purchased()
# ==============================================================================

func update() -> void:
	if not item:
		return
	
	if not is_node_ready():
		await ready
	
	_name_label.text = item.get_display_name()
	_tooltip_grabber.text = item.get_display_name()
	_tooltip_grabber.subtext = item.get_description()
	_icon_rect.texture = item.get_icon()
	_cost_label.text = str(item.get_cost())
	
	if not item.is_visible():
		hide()
		return
	
	show()
	
	if item.is_purchased():
		_icon_rect.modulate = Color.DARK_GRAY
		_checkmark.show()
		_lock.hide()
		
		if _hovered:
			_hover_tween = create_tween().set_parallel()
			_hover_tween.tween_property(_hover_anchor, "position", HOVER_ANIM_BEGIN_OFFSET, HOVER_ANIM_DURATION).from(Vector2.ZERO)
			_hover_tween.tween_property(_hover_anchor, "modulate", Color.TRANSPARENT, HOVER_ANIM_DURATION).from(Color.WHITE)
			_hovered = false
		
		return
	
	_checkmark.hide()
	
	if item.is_locked():
		_icon_rect.modulate = Color.DARK_GRAY
		_lock.show()
		
		if _hovered:
			_hover_tween = create_tween().set_parallel()
			_hover_tween.tween_property(_hover_anchor, "position", HOVER_ANIM_BEGIN_OFFSET, HOVER_ANIM_DURATION).from(Vector2.ZERO)
			_hover_tween.tween_property(_hover_anchor, "modulate", Color.TRANSPARENT, HOVER_ANIM_DURATION).from(Color.WHITE)
			_hovered = false
		
		return
	
	_icon_rect.modulate = Color.WHITE
	_lock.hide()


static func create() -> TokenShopItemDisplay:
	return load("res://engine/scenes/token_shop/token_shop_item_display.tscn").instantiate()


func _on_icon_mouse_entered() -> void:
	if not item.is_locked() and not item.is_purchased():
		_hovered = true
		_hover_tween = create_tween().set_parallel()
		_hover_tween.tween_property(_hover_anchor, "position", Vector2.ZERO, HOVER_ANIM_DURATION).from(HOVER_ANIM_BEGIN_OFFSET)
		_hover_tween.tween_property(_hover_anchor, "modulate", Color.WHITE, HOVER_ANIM_DURATION).from(Color.TRANSPARENT)
		_hover_tween.tween_property(_icon_rect, "modulate", ICON_COVERED_MODULATE, HOVER_ANIM_DURATION).from(Color.WHITE)


func _on_icon_mouse_exited() -> void:
	_hovered = false
	if not item.is_locked() and not item.is_purchased():
		_hover_tween = create_tween().set_parallel()
		_hover_tween.tween_property(_hover_anchor, "position", HOVER_ANIM_BEGIN_OFFSET, HOVER_ANIM_DURATION).from(Vector2.ZERO)
		_hover_tween.tween_property(_hover_anchor, "modulate", Color.TRANSPARENT, HOVER_ANIM_DURATION).from(Color.WHITE)
		_hover_tween.tween_property(_icon_rect, "modulate", Color.WHITE, HOVER_ANIM_DURATION).from(ICON_COVERED_MODULATE)


func _on_tooltip_grabber_interacted() -> void:
	if not item.is_locked() and not item.is_purchased():
		purchased.emit()
