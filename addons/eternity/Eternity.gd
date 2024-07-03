@tool
extends EditorPlugin
class_name Eternity

# ==============================================================================
const DEFAULTS_FILE_PATH := "res://.data/eternity/defaults.cfg"
# ==============================================================================
static var _defaults_cfg := EternalFile.new()

static var path := "" :
	set(value):
		var different := path != value
		path = value
		if different:
			_reload_file()

static var _save_cfg: EternalFile
# ==============================================================================

func _enter_tree() -> void:
	add_autoload_singleton("__EternityInitializer", "res://addons/eternity/EternityInitializer.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("__EternityInitializer")


static func save() -> void:
	if path.is_empty():
		return
	
	_save_cfg.clear()
	
	for section in _defaults_cfg.get_sections():
		var script := UserClassDB.class_get_script(section)
		for key in _defaults_cfg.get_section_keys(section):
			_save_cfg.set_value(section, key, script[key])
	
	_save_cfg.save(path)


static func _reload_file() -> void:
	if path.is_empty():
		return
	
	_save_cfg = EternalFile.new()
	_save_cfg.load(path)
	
	for section in _defaults_cfg.get_sections():
		var script := UserClassDB.class_get_script(section)
		for key in _defaults_cfg.get_section_keys(section):
			if not key in script:
				push_error("Invalid key '%s' under section '%s': Could not find the key in the class." % [key, section])
				continue
			
			script.set(key, _save_cfg.get_value(section, key, _defaults_cfg.get_value(section, key)))


static func stringify(variable: Variant) -> String:
	match typeof(variable):
		TYPE_FLOAT:
			var string := String.num(variable)
			if not "." in string:
				return string + ".0"
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [stringify(variable.x), stringify(variable.y)]
		TYPE_RECT2:
			return "Rect2(%s, %s, %s, %s)" % [
				stringify(variable.position.x),
				stringify(variable.position.y),
				stringify(variable.size.x),
				stringify(variable.size.y)
			]
		TYPE_VECTOR3:
			return "Vector3(%s, %s, %s)" % [
				stringify(variable.x),
				stringify(variable.y),
				stringify(variable.z)
			]
		TYPE_TRANSFORM2D:
			return "Transform2D(%s, %s, %s, %s, %s, %s)" % [
				stringify(variable.x.x),
				stringify(variable.x.y),
				stringify(variable.y.x),
				stringify(variable.y.y),
				stringify(variable.o.x),
				stringify(variable.o.y)
			]
		TYPE_VECTOR4:
			return "Vector4(%s, %s, %s, %s)" % [
				stringify(variable.x),
				stringify(variable.y),
				stringify(variable.z),
				stringify(variable.w)
			]
		TYPE_PLANE:
			return "Plane(%s, %s, %s, %s)" % [
				stringify(variable.x),
				stringify(variable.y),
				stringify(variable.z),
				stringify(variable.d)
			]
		TYPE_QUATERNION:
			return "Quaternion(%s, %s, %s, %s)" % [
				stringify(variable.x),
				stringify(variable.y),
				stringify(variable.z),
				stringify(variable.w)
			]
		TYPE_AABB:
			return "AABB(%s, %s, %s, %s, %s, %s)" % [
				stringify(variable.position.x),
				stringify(variable.position.y),
				stringify(variable.position.z),
				stringify(variable.size.x),
				stringify(variable.size.y),
				stringify(variable.size.z)
			]
		TYPE_BASIS:
			return "Basis(%s, %s, %s, %s, %s, %s, %s, %s, %s)" % [
				stringify(variable.x.x),
				stringify(variable.x.y),
				stringify(variable.x.z),
				stringify(variable.y.x),
				stringify(variable.y.y),
				stringify(variable.y.z),
				stringify(variable.z.x),
				stringify(variable.z.y),
				stringify(variable.z.z)
			]
		TYPE_TRANSFORM3D:
			return "Transform3D(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % [
				stringify(variable.basis.x.x),
				stringify(variable.basis.x.y),
				stringify(variable.basis.x.z),
				stringify(variable.basis.y.x),
				stringify(variable.basis.y.y),
				stringify(variable.basis.y.z),
				stringify(variable.basis.z.x),
				stringify(variable.basis.z.y),
				stringify(variable.basis.z.z),
				stringify(variable.origin.x),
				stringify(variable.origin.y),
				stringify(variable.origin.z),
			]
		TYPE_PROJECTION:
			return "Projection(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % [
				stringify(variable.x.x),
				stringify(variable.x.y),
				stringify(variable.x.z),
				stringify(variable.x.w),
				stringify(variable.y.x),
				stringify(variable.y.y),
				stringify(variable.y.z),
				stringify(variable.y.w),
				stringify(variable.z.x),
				stringify(variable.z.y),
				stringify(variable.z.z),
				stringify(variable.z.w),
				stringify(variable.w.x),
				stringify(variable.w.y),
				stringify(variable.w.z),
				stringify(variable.w.w)
			]
		TYPE_COLOR:
			return "Color(%s, %s, %s, %s)" % [
				stringify(variable.r),
				stringify(variable.g),
				stringify(variable.b),
				stringify(variable.a)
			]
		TYPE_OBJECT:
			if not is_instance_valid(variable):
				return "null"
			if variable.get_script():
				var class_string := UserClassDB.get_class_from_script(variable.get_script())
				return "Object(%s,%s)" % [class_string, ",".join(variable.get_property_list().filter(func(prop: Dictionary):
					return prop.name in variable and prop.name != "script" # we are assigning the script ourselves
				).map(func(prop: Dictionary) -> String:
					return "\"%s\":%s" % [prop.name, stringify(variable[prop.name])]
				))]
			else:
				return var_to_str(variable)
		TYPE_DICTIONARY:
			return "{\n" + ",\n".join(variable.keys().map(func(key: Variant) -> String:
				return stringify(key) + ": " + stringify(variable[key])
			)) + "\n}"
		TYPE_ARRAY:
			variable = variable as Array
			var stringified: PackedStringArray = variable.map(func(a: Variant) -> String:
				return stringify(a)
			)
			if variable.is_typed():
				var typed_builtin: int = variable.get_typed_builtin()
				var type := String(UserClassDB.get_class_from_script(variable.get_typed_script())) if typed_builtin == TYPE_OBJECT else type_string(typed_builtin)
				return "Array[%s]([%s])" % [type, ", ".join(stringified)]
			else:
				return "[%s]" % ", ".join(stringified)
		TYPE_PACKED_FLOAT32_ARRAY:
			return "PackedFloat32Array(%s)" % [", ".join(Array(variable).map(func(a: float): return stringify(a)))]
		TYPE_PACKED_FLOAT64_ARRAY:
			return "PackedFloat64Array(%s)" % [", ".join(Array(variable).map(func(a: float): return stringify(a)))]
		TYPE_PACKED_VECTOR2_ARRAY:
			return "PackedVector2Array(%s)" % [", ".join(Array(variable).map(func(a: Vector2): return stringify(a)))]
		TYPE_PACKED_VECTOR3_ARRAY:
			return "PackedVector3Array(%s)" % [", ".join(Array(variable).map(func(a: Vector3): return stringify(a)))]
		TYPE_PACKED_COLOR_ARRAY:
			return "PackedColorArray(%s)" % [", ".join(Array(variable).map(func(a: Color): return stringify(a)))]
	
	return var_to_str(variable)


static func parse(string: String) -> Variant:
	match string:
		"null":
			return null
		"false":
			return false
		"true":
			return true
	
	if string.is_valid_int():
		return string.to_int()
	if string.is_valid_float():
		return string.to_float()
	
	if string.match("\"*\""):
		return string.trim_prefix("\"").trim_suffix("\"")
	if string.match("&\"*\""):
		return StringName(string.trim_prefix("&\"").trim_suffix("\""))
	
	if string.match("{*}"):
		var split := string.trim_prefix("{\n").trim_suffix("\n}").split(",\n")
		var dict := {}
		
		var i := 0
		while i < split.size():
			var slice := split[i]
			
			var slices := _split_values(slice, ":")
			
			var key = parse(slices[0])
			var value = parse(slices[1])
			
			dict[key] = value
			
			i += 1
		
		return dict
	
	if string.match("Array[*]([*])"):
		var typed_string := string.trim_prefix("Array[").get_slice("]", 0)
		var class_string := &""
		var type := TYPE_NIL
		var script: Script
		
		if UserClassDB.class_exists(typed_string):
			script = UserClassDB.class_get_script(typed_string)
			class_string = script.get_instance_base_type()
			type = TYPE_OBJECT
		else:
			var types := range(TYPE_MAX).map(func(t: Variant.Type): return type_string(t))
			if typed_string in types:
				type = types.find(typed_string) as Variant.Type
			else:
				type = TYPE_OBJECT
				class_string = typed_string
		
		var arr := Array([], type, class_string, script)
		arr.assign(parse(string.trim_prefix("Array[%s](" % typed_string).trim_suffix(")")))
		return arr
	
	if string.match("[*]"):
		return Array(_split_values(string.trim_prefix("[").trim_suffix("]"), ",")).map(func(s: String): return parse(s))
	
	if string.match("Object(*,*)"):
		var class_string := string.trim_prefix("Object(").get_slice(",", 0)
		if UserClassDB.class_can_instantiate(class_string):
			var instance: Object = UserClassDB.instantiate(class_string)
			
			var props_string := string.trim_prefix("Object(" + class_string + ",").trim_suffix(")")
			
			var key_value_pairs := _split_values(props_string, ",")
			
			for pair in key_value_pairs:
				var split := _split_values(pair, ":")
				var key = parse(split[0])
				var value = parse(split[1])
				
				instance.set(key, value)
			
			return instance
	
	return str_to_var(string)


static func _split_values(string: String, delimeter: String) -> PackedStringArray:
	var slices := PackedStringArray()
	
	var slice := ""
	var escape := false
	var in_string := false
	var group_level := 0
	for c in string:
		if c == "\\":
			escape = true
		
		if c == "(" and not in_string:
			group_level += 1
		if c == ")" and not in_string:
			group_level -= 1
		
		if c == "\"" and not escape:
			in_string = not in_string
		
		if c == delimeter and not in_string and group_level == 0:
			slices.append(slice.strip_edges())
			slice = ""
			continue
		
		slice += c
		
		escape = false
	
	slices.append(slice.strip_edges())
	
	return slices
