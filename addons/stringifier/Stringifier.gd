extends Object
class_name Stringifier

# ==============================================================================

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
				var class_string := UserClassDB.script_get_class(variable.get_script())
				
				if variable.has_method("_export"):
					var export = variable._export()
					if export is Array and not export.is_typed():
						return "%s(%s)" % [class_string, stringify(export).trim_prefix("[").trim_suffix("]")]
					return "%s(%s)" % [class_string, stringify(export)]
				
				return "Object(%s,%s)" % [class_string, ",".join(variable.get_property_list().filter(func(prop: Dictionary):
					return prop.name in variable and prop.name != "script" # we are assigning the script ourselves
				).map(func(prop: Dictionary) -> String:
					return "\"%s\":%s" % [prop.name, stringify(variable[prop.name])]
				))]
			else:
				return var_to_str(variable)
		TYPE_DICTIONARY:
			if variable.is_empty():
				return "{}"
			return "{\n" + ",\n".join(variable.keys().map(func(key: Variant) -> String:
				return stringify(key) + ": " + stringify(variable[key])
			)) + "\n}"
		TYPE_ARRAY:
			variable = variable as Array
			var stringified: PackedStringArray = variable.map(stringify)
			if variable.is_typed():
				var typed_builtin: int = variable.get_typed_builtin()
				var type := String(UserClassDB.script_get_class(variable.get_typed_script())) if typed_builtin == TYPE_OBJECT else type_string(typed_builtin)
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
	if string.begins_with("{"):
		return _Helpers.parse_dictionary(string)
	elif string.begins_with("["):
		return _Helpers.parse_array(string)
	elif string.match("Array[*]([*])"):
		return _Helpers.parse_typed_array(string)
	elif string.begins_with("Object("):
		return _Helpers.parse_object(string)
	elif string.match("*(*)"):
		var value := _Helpers.parse_importer(string)
		if value != null:
			return value
	
	return str_to_var(string)


static func split_ignoring_nested(s: String, delimiter: String) -> PackedStringArray:
	var parts := PackedStringArray()
	var current := ""
	var inside_string := false
	var depth := 0
	
	var i := 0
	while i < s.length():
		var c := s[i]
		
		if c == "\"" and (i == 0 or s[i - 1] != "\\"):
			inside_string = not inside_string
		elif not inside_string:
			if c == "(" or c == "{" or c == "[":
				depth += 1
			elif c == ")" or c == "}" or c == "]":
				depth -= 1
			elif c == delimiter[0] and depth == 0 and s.substr(i, delimiter.length()) == delimiter:
				parts.append(current.strip_edges())
				current = ""
				i += delimiter.length()
				continue
		
		current += c
		
		i += 1
	
	if current != "":
		parts.append(current.strip_edges())
	
	return parts


static func get_depth(s: String, opening_char: String, closing_char: String) -> int:
	var inside_string := false
	var depth := 0
	var escaped := false
	
	var i := 0
	while i < s.length():
		var c := s[i]
		
		if c == "\\" and not escaped:
			escaped = true
			i += 1
			continue
		if c == "\"" and not escaped:
			inside_string = not inside_string
		elif not inside_string:
			if c == opening_char:
				depth += 1
			elif c == closing_char:
				depth -= 1
		
		escaped = false
		i += 1
	
	return depth


class _Helpers:
	static func parse_dictionary(s: String) -> Dictionary:
		s = s.trim_prefix("{").trim_suffix("}")
		
		if s.strip_edges().is_empty():
			return {}
		
		var dict := {}
		var entries := Stringifier.split_ignoring_nested(s, ",\n")
		
		for entry in entries:
			var kv := Stringifier.split_ignoring_nested(entry, ": ")
			dict[Stringifier.parse(kv[0])] = Stringifier.parse(kv[1])
		
		return dict
	
	static func parse_array(s: String) -> Array:
		s = s.trim_prefix("[").trim_suffix("]")
		
		var parts := Stringifier.split_ignoring_nested(s, ", ")
		var arr := []
		
		for part in parts:
			arr.append(Stringifier.parse(part))
		
		return arr
	
	static func parse_typed_array(s: String) -> Array:
		var cname := s.trim_prefix("Array[").get_slice("]", 0)
		var type := range(TYPE_MAX).map(func(t: int): return type_string(t)).find(cname)
		
		if type < 0:
			type = TYPE_OBJECT
		
		var type_cname := &""
		if type == TYPE_OBJECT:
			if UserClassDB.class_exists(cname):
				type_cname = UserClassDB.class_get_script(cname).get_instance_base_type()
			else:
				type_cname = cname
		
		return Array(
			parse_array(s.trim_prefix("Array[" + cname + "](").trim_suffix(")")),
			type,
			type_cname,
			UserClassDB.class_get_script(cname)
		)
	
	static func parse_object(s: String) -> Object:
		s = s.trim_prefix("Object(").trim_suffix(")")
		
		var parts := Stringifier.split_ignoring_nested(s, ",")
		var cname := parts[0]
		
		if not UserClassDB.class_exists(cname):
			return str_to_var(s)
		
		var obj := UserClassDB.instantiate(cname)
		
		for i in range(1, parts.size()):
			var kv := Stringifier.split_ignoring_nested(parts[i], ":")
			obj.set(kv[0].trim_prefix("\"").trim_suffix("\""), Stringifier.parse(kv[1]))
		
		return obj
	
	static func parse_importer(s: String) -> Object:
		var class_string := s.get_slice("(", 0)
		if not UserClassDB.class_exists(class_string):
			return null
		
		var args: Array = Stringifier.parse("[" + s.trim_prefix(class_string + "(").trim_suffix(")") + "]")
		
		var script := UserClassDB.class_get_script(class_string)
		if script.has_method("_static_import"):
			return script._static_import.callv([class_string] + args)
		
		if script.has_method("_import"):
			return script._import.callv(args)
		
		var instance := UserClassDB.instantiate(class_string)
		instance._import.callv(args)
		return instance
