@tool
extends HBoxContainer
class_name StageDetails

# ==============================================================================
@export var stage: Stage :
	set(value):
		if stage == value:
			return
		
		if stage and stage.changed.is_connected(update):
			stage.changed.disconnect(update)
		
		stage = value
		
		if stage:
			update()
			
			stage.changed.connect(update)
var hovered := false
# ==============================================================================
@onready var _stage_texture: TextureRect = %StageTexture
@onready var _lock: TextureRect = %Lock
@onready var _checkmark: TextureRect = %Checkmark
@onready var _name_label: Label = %NameLabel
@onready var _unknown_info: Control = %UnknownInfo
@onready var _special_info: HBoxContainer = %SpecialInfo
@onready var _complete_info: HBoxContainer = %CompleteInfo
@onready var _info_container: HBoxContainer = %InfoContainer
@onready var _power_label: Label = %PowerLabel
@onready var _lore_label: Label = %LoreLabel
@onready var _monster_label: Label = %MonsterLabel
@onready var _size_label: Label = %SizeLabel
@onready var _stage_mods_container: HBoxContainer = %StageModsContainer
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal interacted()
# ==============================================================================

func _process(_delta: float) -> void:
	if hovered and Input.is_action_just_pressed("interact"):
		interacted.emit()


func update() -> void:
	if not is_node_ready():
		await ready
	
	_info_container.hide()
	_complete_info.hide()
	_stage_texture.show()
	_unknown_info.hide()
	_special_info.hide()
	_checkmark.hide()
	_lock.hide()
	
	if stage.locked:
		_lore_label.text = "STAGE_LORE_LOCKED"
		_name_label.text = "LOCKED"
		_stage_texture.hide()
		_unknown_info.show()
		_lock.show()
		_stage_mods_container.hide()
		return
	
	_name_label.text = "STAGE_" + stage.name.to_snake_case().to_upper()
	_lore_label.text = "LORE_" + stage.name.to_snake_case().to_upper()
	
	_stage_texture.texture = stage.create_big_icon()
	
	for child in _stage_mods_container.get_children():
		_stage_mods_container.remove_child(child)
		child.queue_free()
	
	for mod in stage.mods:
		var icon := StageModIcon.create(mod)
		_stage_mods_container.add_child(icon)
	
	_stage_mods_container.show()
	
	if stage.completed:
		_complete_info.show()
		_checkmark.show()
		return
	
	if stage is SpecialStage:
		_special_info.show()
		return
	
	_power_label.text = str(stage.min_power) + "-" + str(stage.max_power)
	_monster_label.text = str(stage.monsters)
	_size_label.text = str(stage.size.x * stage.size.y)
	
	_info_container.show()


func _on_texture_container_mouse_entered() -> void:
	if stage and not stage.locked and not stage.completed:
		_animation_player.play("hover")
		hovered = true


func _on_texture_container_mouse_exited() -> void:
	if stage and not stage.locked and not stage.completed:
		_animation_player.play_backwards("hover")
		hovered = false
