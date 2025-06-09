@tool
extends AnnotatedTexture
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
@export var _origin_stage: Stage : set = _set_origin_stage, get = get_origin_stage
# ==============================================================================
var _cell: WeakRef = null :
	set(value):
		var old := _cell
		if old != null and value == null:
			reset()
		
		_cell = value
		
		if old == null and value != null:
			_ready()
		
		cell_changed.emit()

var _origin_stage_weakref: WeakRef = null

var _texture: Texture2D = null : get = get_texture
var _material: Material = null : get = get_material

var _theme: Theme = null :
	get:
		if _theme == null and _origin_stage != null:
			_theme = _origin_stage.get_theme()
		return _theme

var _tweens: Array[Tween] = []

var initialized := false
var reloaded := false
# ==============================================================================
signal cell_changed()
# ==============================================================================

#region internals

@warning_ignore("shadowed_variable")
func _init(stage: Stage = Stage.get_current()) -> void:
	_origin_stage = stage


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			for tween in _tweens:
				tween.kill()


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	_texture.draw(to_canvas_item, pos, modulate * get_modulate(), transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	_texture.draw_rect(to_canvas_item, rect, tile, modulate * get_modulate(), transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate * get_modulate(), transpose, clip_uv)


func _get_width() -> int:
	return _texture.get_width()


func _get_height() -> int:
	return _texture.get_height()


func _has_alpha() -> bool:
	return _texture.has_alpha()


func _is_pixel_opaque(x: int, y: int) -> bool:
	if x < 0 or y < 0:
		return true
	if x > get_width() or y > get_width():
		return true
	return _texture.get_image().get_pixel(x, y).a8 != 0


func _export_packed() -> Array:
	var args := []
	
	var owner := Eternity.get_processing_owner()
	if not owner.has_method("get_stage") or owner.get_stage() != self.get_origin_stage():
		args.append(get_origin_stage())
	
	if not initialized:
		args.append(false)
	
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
		var owner := Eternity.get_processing_owner()
		if owner.has_method("get_stage"):
			Eternity.get_processing_file().loaded.connect(func(_path: String) -> void:
				object._origin_stage = owner.get_stage()
			, CONNECT_ONE_SHOT)
		else:
			Debug.log_error("Could not obtain the stage for object '%s'." % object)
	
	if i >= args.size():
		return object
	
	if args[i] is bool and args[i] == false:
		var bool_count := 0
		while args.size() > i + bool_count:
			if not args[i + bool_count] is bool:
				break
			bool_count += 1
		
		var bool_count_in_props := 0
		for prop in object.get_property_list():
			if prop.name == "CellObject.gd":
				break
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_STORAGE:
				if prop.type != TYPE_BOOL and prop.type != TYPE_NIL:
					break
				bool_count_in_props += 1
		
		if bool_count_in_props < bool_count:
			object.initialized = true
			i += 1
	else:
		object.initialized = true
	
	object.reloaded = true
	
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


func _to_string() -> String:
	return "<%s#%d>" % [UserClassDB.script_get_identifier(get_script()), get_instance_id()]

#endregion

func set_cell(cell: CellData) -> void:
	_cell = weakref(cell) if cell else null


func get_cell() -> CellData:
	return _cell.get_ref() if _cell else null


func get_tree() -> SceneTree:
	return Engine.get_main_loop()


func _set_origin_stage(value: Stage) -> void:
	if _origin_stage and _origin_stage.changed.is_connected(_on_stage_changed):
		_origin_stage.changed.disconnect(_on_stage_changed)
	
	_origin_stage_weakref = weakref(value)
	
	_on_stage_changed()
	if value:
		value.changed.connect(_on_stage_changed)


func _on_stage_changed() -> void:
	_theme = null
	_texture = null
	_material = null
	emit_changed()


func get_origin_stage() -> Stage:
	if _origin_stage_weakref == null:
		return null
	return _origin_stage_weakref.get_ref()

#region virtuals

## Virtual method. Called immediately after initializing. Can be overridden to run
## code every time this object is created, e.g. to connect to effects.
## [br][br][b]Note:[/b] Is called every time this object is initialized, even when
## reloading the stage.
func _ready() -> void:
	pass


## Returns whether an object of this type can spawn. If this returns [code]false[/code],
## a [Cell] that attempts to spawn this object will try again.
static func can_spawn(object: Script) -> bool:
	return object._can_spawn()


## Virtual method to override the return value of [method can_spawn].
static func _can_spawn() -> bool:
	return true


## Returns the object's texture.
## [br][br][b]Note:[/b] Each [CellObject] is a [Texture2D] by itself, so it can be used as
## a texture. This method simply returns the underlying [Texture2D] instance.
func get_texture() -> Texture2D:
	if not _texture:
		_texture = _get_texture()
		if _texture:
			_texture.changed.connect(emit_changed)
	return _texture


## Called when this object's [Texture2D] is queried.
## [br][br]After this is called, the texture is cached and this method is not called
## anymore on this object.
func _get_texture() -> Texture2D:
	return null


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
	_interact()
	
	_hover()
	
	Effects.object_interacted(self)


## Virtual method to react to this object being interacted with.
func _interact() -> void:
	pass


## Notifies this object aht the player used secondary interact (right-click or E) on this object.
func notify_secondary_interacted() -> void:
	_secondary_interact()


## Virtual method to react to this object being secondary interacted with.
func _secondary_interact() -> void:
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
	
	StageInstance.get_current().get_board().get_camera().shake()
	
	_kill()
	
	clear()
	
	Effects.object_killed(self)


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
	
	Effects.object_revealed(self, true)


## Virtual method to react to this object being revealed. Called when the player
## actively reveals this object, typically by directly opening this cell or chording
## an adjacent cell.
func _reveal_active() -> void:
	pass


## Called when the player passively reveals this object, typically by using
## items or other abilities.
func notify_revealed_passive() -> void:
	_reveal_passive()
	
	Effects.object_revealed(self, false)


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
	initialized = true
	_spawn()


func _cell_enter() -> void:
	pass


func notify_cell_entered() -> void:
	if Eternity.get_processing_file() != null:
		await Eternity.loaded
	
	var contribution := get_value_contribution()
	for cell in get_cell().get_nearby_cells():
		cell.value += contribution
	
	_cell_enter()


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

#endregion

#region utilities

## Clears this [CellObject], setting the cell's object to [code]null[/code].
func clear() -> void:
	_clear()
	
	get_cell().clear_object()


## Creates a new [Tween].
## [br][br]The [Tween] will start automatically on the next process frame or physics frame (depending on [enum Tween.TweenProcessMode]).
## [br][br]The [Tween] will automatically be killed when this [CellObject] gets freed.
func create_tween() -> Tween:
	var tween := get_tree().create_tween()
	_tweens.append(tween)
	tween.finished.connect(func() -> void: _tweens.erase(tween), CONNECT_ONE_SHOT)
	return tween


@warning_ignore("shadowed_variable")
func move_to_cell(cell: CellData) -> void:
	# TODO: this should animate the texture from the old cell to the new one
	get_cell().move_object_to(cell)


func flee() -> void:
	# TODO: show animation
	clear()


func get_quest() -> Quest:
	return Quest.get_current()


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
	return GuiLayer.get_texture_tweener().tween_texture(self, get_cell().get_stage_instance().get_board().get_global_at_cell_position(get_cell().get_position()), position, duration, 4.0)


func get_theme_icon(name: StringName, theme_type: StringName = "Cell") -> Texture2D:
	var icon: Texture2D
	if _theme and _theme.has_icon(name, theme_type):
		icon = _theme.get_icon(name, theme_type)
	else:
		icon = load("res://Engine/Resources/default_theme.tres").get_icon(name, theme_type)
	
	if icon is CustomTextureBase:
		return icon.create()
	return icon

#endregion
