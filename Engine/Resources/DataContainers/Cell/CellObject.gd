@tool
@abstract
extends AnnotatedTextureNode
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
@export var _origin_stage: Stage = null : set = _set_origin_stage, get = get_origin_stage
# ==============================================================================
var _material: Material = null : get = get_material

var _theme: Theme = null :
	get:
		if _theme == null and _origin_stage != null:
			_theme = _origin_stage.get_theme()
		return _theme

#var initialized := false
#var reloaded := false
# ==============================================================================

#region internals

func _init(stage: Stage = null) -> void:
	_origin_stage = stage


func _ready() -> void:
	if Eternity.get_processing_file() != null:
		await Eternity.get_processing_file().loaded
		_cell_enter()
		return
	
	var contribution := get_value_contribution()
	if contribution:
		for cell in get_cell().get_nearby_cells():
			cell.value += contribution
	
	_cell_enter()
	_spawn()


func _export_packed_enabled() -> bool:
	return get_child_count() == 0


func _export_packed() -> Array:
	var args := []
	
	var processing_owner := Eternity.get_processing_owner()
	if not processing_owner.has_method("get_stage") or processing_owner.get_stage() != self.get_origin_stage():
		args.append(get_origin_stage())
	
	#if not initialized:
		#args.append(false)
	
	for prop in get_property_list():
		if prop.name == "CellObject.gd":
			return args
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_STORAGE:
			args.append(get(prop.name))
	
	return args


static func _import_packed_static_v(script: String, args: Array) -> CellObject:
	var object: CellObject = UserClassDB.instantiate(script)
	
	var i := 0
	if not args.is_empty() and args[0] is Stage:
		object._origin_stage = args[0]
		i = 1
	else:
		var processing_owner := Eternity.get_processing_owner()
		if processing_owner.has_method("get_stage"):
			Eternity.get_processing_file().loaded.connect(func(_path: String) -> void:
				object._origin_stage = processing_owner.get_stage()
			, CONNECT_ONE_SHOT)
		else:
			Debug.log_error("Could not obtain the stage for object '%s'." % object)
	
	if i >= args.size():
		return object
	
	#if args[i] is bool and args[i] == false:
		#var bool_count := 0
		#while args.size() > i + bool_count:
			#if not args[i + bool_count] is bool:
				#break
			#bool_count += 1
		
		#var bool_count_in_props := 0
		#for prop in object.get_property_list():
			#if prop.name == "CellObject.gd":
				#break
			#if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_STORAGE:
				#if prop.type != TYPE_BOOL and prop.type != TYPE_NIL:
					#break
				#bool_count_in_props += 1
		
		#if bool_count_in_props < bool_count:
			#object.initialized = true
			#i += 1
	#else:
		#object.initialized = true
	
	#object.reloaded = true
	
	if i >= args.size():
		return object
	
	for prop in object.get_property_list():
		if prop.name == "CellObject.gd":
			return object
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_STORAGE:
			object.set(prop.name, args[i])
			i += 1
			if i >= args.size():
				return object
	
	return object

#endregion

func get_cell() -> CellData:
	return get_parent()


func _set_origin_stage(value: Stage) -> void:
	if _origin_stage and _origin_stage.changed.is_connected(_on_stage_changed):
		_origin_stage.changed.disconnect(_on_stage_changed)
	
	_origin_stage = value
	
	_on_stage_changed()
	if value:
		value.changed.connect(_on_stage_changed)


func _on_stage_changed() -> void:
	_theme = null
	_texture = null
	_material = null
	emit_changed()


func get_stage() -> Stage:
	var base := get_parent()
	while base != null and base is not Stage:
		base = base.get_parent()
	return base


func get_stage_instance() -> StageInstance:
	var base := get_parent()
	while base != null and base is not StageInstance:
		base = base.get_parent()
	return base


func get_origin_stage() -> Stage:
	return _origin_stage

#region virtuals

## Returns whether an object of this type can spawn. If this returns [code]false[/code],
## a [Cell] that attempts to spawn this object will try again.
static func can_spawn(object: Script) -> bool:
	return object._can_spawn()


## Virtual method to override the return value of [method can_spawn].
static func _can_spawn() -> bool:
	return true


## Returns the object's texture source. This must be a built-in [Texture2D]-derived class.
func get_source() -> Texture2D:
	return _get_source()


## Called when this object's source is used. Should return a built-in [Texture2D]-derived class.
func _get_source() -> Texture2D:
	if _texture is TextureSequence:
		return _texture.get_texture(0)
	return null


## Returns this object's [Material], to be applied whenever its texture is used.
func get_material() -> Material:
	if _material:
		return _material
	
	var override := _get_material()
	if override:
		_material = override
		return override
	
	var palette := get_palette()
	if palette:
		var shader := ShaderMaterial.new()
		shader.shader = preload("res://Engine/Scenes/StageScene/Board/CellObject.gdshader")
		shader.set_shader_parameter("palette", palette)
		shader.set_shader_parameter("palette_enabled", true)
		_material = shader
		return shader
	
	return null


## Virtual method to override this object's material. If a value other than [code]null[/code]
## is returned, any other [Material] will be overridden by the returned one.
## [br][br][b]Note:[/b] If [method _get_palette] does not return [code]null[/code],
## that value will be used by default. However, this method will override that [Material]
## if it does not return [code]null[/code].
func _get_material() -> Material:
	return null


## Returns this object's [Color] modulation.
func get_modulate() -> Color:
	return _get_modulate()


## Virtual method to override the return value of [method get_modulate].
func _get_modulate() -> Color:
	return Color.WHITE


## Returns the object's color palette, to be inserted into the cell's shader.
func get_palette() -> Texture2D:
	return _get_palette()


## Virtual method to override the object's color palette, to be inserted into the cell's shader.
func _get_palette() -> Texture2D:
	return null


## Notifies this object that the player has interacted (left-click or Q) with it.
func notify_interacted() -> void:
	interact()
	
	_hover()
	
	EffectManager.propagate(get_stage_instance().get_object_effects().interacted, [self])


## Interacts with this object.
func interact() -> void:
	_interact()


## Virtual method to react to this object being interacted with.
func _interact() -> void:
	pass


## Notifies this object aht the player used secondary interact (right-click or E) on this object.
func notify_second_interacted() -> void:
	second_interact()


## Secondary-interacts with this object.
func second_interact() -> void:
	_second_interact()


## Virtual method to react to this object being secondary-interacted with.
func _second_interact() -> void:
	pass


## Notifies this object that the player started hovering over this object.
func notify_hovered() -> void:
	_hover()


## Virtual method to react to being hovered. Called when the player starts hovering
## over this object. Also called when the player interacts with this object.
func _hover() -> void:
	pass


## Notifies this object that the player stopped hovering over this object.
func notify_unhovered() -> void:
	_unhover()


## Virtual method to react to the player stopping hovering over this object.
func _unhover() -> void:
	pass


## Kills this object.
func kill() -> void:
	get_cell().shatter(get_source())
	
	get_cell().get_stage_instance().get_board().get_camera().shake()
	
	_kill()
	
	clear()
	
	EffectManager.propagate(get_stage_instance().get_object_effects().killed, [self])


## Virtual method to react to being killed.
func _kill() -> void:
	pass


## Virtual method to react to being cleared, i.e. removed from the [Cell].
func _clear() -> void:
	pass


## Trigger any effects that occur when this object is revealed. If the player actively
## opened the cell, typically by directly opening this cell or chording an adjacent
## cell, [code]active[/code] should be [code]true[/code]. Otherwise, [code]active[/code]
## should be [code]false[/code].
func notify_revealed(active: bool) -> void:
	_reveal()
	
	if active:
		notify_revealed_active()
	else:
		notify_revealed_passive()


## Virtual method to react to this object being revealed by any means. This is called
## [b]before[/b] [method _reveal_active] or [method _reveal_passive].
func _reveal() -> void:
	pass


## Trigger any effects that occur when this object is actively revealed, typically
## by directly opening this cell or chording an adjacent cell.
func notify_revealed_active() -> void:
	_reveal_active()


## Virtual method to react to this object being revealed. Called when the player
## actively reveals this object, typically by directly opening this cell or chording
## an adjacent cell.
func _reveal_active() -> void:
	pass


## Called when the player passively reveals this object, typically by using
## items or other abilities.
func notify_revealed_passive() -> void:
	_reveal_passive()


## Virtual method to react to being passively revealed. Called when the player passively
## reveals this object, typically by using items or other abilities.
func _reveal_passive() -> void:
	pass


## Returns this object's score value for the charitable reward.
func get_charitable_amount() -> int:
	return _get_charitable_amount()


## Virtual method. Called at the end of a stage when determining the charitable score.
## Should return the amount of points this object gives.
func _get_charitable_amount() -> int:
	return 0


## Returns whether this object is charitable, i.e. whether this object's charitable
## value should be considered when determining the player's charitable score.
func is_charitable() -> bool:
	return _is_charitable()


## Virtual method. Called at the end of a stage when determining the charitable score.
## Should return [code]true[/code] if this object gives any charitable score,
## or [code]false[/code] if not.
func _is_charitable() -> bool:
	return false


## Resets all properties modified by this object. This should be called when the object
## is removed from its [Cell].
func reset() -> void:
	var contribution := get_value_contribution()
	if contribution:
		for cell in get_cell().get_nearby_cells():
			cell.value -= contribution
	
	_reset()


## Virtual method. Called when this object is removed from its [Cell]. Should
## reset all properties modified by this object that should not persist.
func _reset() -> void:
	pass


## Virtual method. Called (once) when this object is first spawned into the [Stage].
## Is not called when reloading the [Stage].
func _spawn() -> void:
	pass


## Notifies the object that is has just been spawned.
func notify_spawned() -> void:
	#initialized = true
	_spawn()


func _cell_enter() -> void:
	pass


## Virtual method. Called when an [Aura] is applied to this object's [Cell].
func _aura_apply() -> void:
	pass


## Notifies the object that an [Aura] was applied to its [Cell].
func notify_aura_applied() -> void:
	_aura_apply()


## Virtual method. Called every time the [Cell]'s [Aura] changes (including after
## it is removed).
func _aura_change() -> void:
	pass


## Notifies the object that the [Aura] of its [Cell] was changed (or removed).
func notify_aura_changed() -> void:
	_aura_change()


## Virtual method. Called when the [Aura] of this object's [Cell] is removed.
func _aura_remove() -> void:
	pass


## Notifies the object that the [Aura] of its [Cell] was removed.
func notify_aura_removed() -> void:
	_aura_remove()


## Virtual method. Should return the value contribution of this [CellObject], i.e.
## the amount that each nearby cell should be increased by.
func _contribute_value() -> int:
	return 0


## Returns the value contribution of this [CellObject], i.e. the amount that each
## nearby cell should be increased by.
func get_value_contribution() -> int:
	return _contribute_value()


func _can_interact() -> bool:
	return false


func can_interact() -> bool:
	return _can_interact()


func _can_second_interact() -> bool:
	return false


func can_second_interact() -> bool:
	return _can_second_interact()


func get_actions() -> Array[Callable]:
	return _get_actions()


func _get_actions() -> Array[Callable]:
	if not can_interact():
		return get_quest().get_action_manager().get_actions(self)
	
	var actions: Array[Callable] = [interact]
	
	if can_second_interact():
		actions.append(second_interact)
	
	actions.append_array(get_quest().get_action_manager().get_actions(self))
	
	return actions

#endregion

#region utilities

## Clears this [CellObject], setting the cell's object to [code]null[/code].
func clear() -> void:
	_clear()
	
	reset()
	
	get_cell().clear_object()


@warning_ignore("shadowed_variable")
func move_to_cell(cell: CellData) -> void:
	# TODO: this should animate the texture from the old cell to the new one
	get_cell().move_object_to(cell)


func flee() -> void:
	# TODO: show animation
	clear()


func handle_fail() -> bool:
	var handled: bool = EffectManager.propagate_mutable(get_stage_instance().get_object_effects().handle_interact_failed, 1, self, false)
	EffectManager.propagate(get_stage_instance().get_object_effects().interact_failed, [self, handled])
	return handled


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_inventory() -> QuestInventory:
	return get_quest().get_inventory()


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_inventory().get_item_count():
		items.append(get_inventory().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_stats().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_stats().life_lose(life, source)


func tween_texture_to(position: Vector2, duration: float = 0.4) -> Tween:
	return GuiLayer.get_texture_tweener().tween_texture(get_texture(), get_cell().get_screen_position(), position, duration, 4.0, get_material())


func get_theme_icon(theme_name: StringName, theme_type: StringName = "Cell") -> Texture2D:
	var icon: Texture2D
	if _theme and _theme.has_icon(theme_name, theme_type):
		icon = _theme.get_icon(theme_name, theme_type)
	else:
		icon = load("res://Engine/Resources/default_theme.tres").get_icon(theme_name, theme_type)
	
	if icon is CustomTextureBase:
		return icon.create()
	return icon

#endregion

@warning_ignore_start("unused_signal")

class ObjectEffects extends EventBus:
	signal used(object: CellObject)
	
	signal interacted(object: CellObject)
	signal handle_interact_failed(object: CellObject, handled: bool)
	signal interact_failed(object: CellObject, handled: bool)
	
	signal second_interacted(object: CellObject)
	signal handle_second_interact_failed(object: CellObject, handled: bool)
	signal second_interact_failed(object: CellObject, handled: bool)
	
	signal killed(object: CellObject)

@warning_ignore_restore("unused_signal")
