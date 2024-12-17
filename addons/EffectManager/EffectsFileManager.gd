extends Object
class_name __EffectsFileManager

# ==============================================================================

static func get_function(function_name: String, allow_create: bool = false) -> Function:
	const BEGIN_LINE := 9
	
	var effects := Effects as GDScript
	
	var function: Function
	
	var lines := effects.source_code.split("\n")
	for i in range(BEGIN_LINE, lines.size()):
		if lines[i].match("static func %s(*) -> *:*" % function_name):
			function = Function.create_from_line(i, -1)
	
	if allow_create:
		function = Function.create_new(function_name)
	
	if not function:
		return null
	
	const SIGNALS_BEGIN_LINE := 3
	
	var signals := __EffectSignals as GDScript
	
	for i in range(SIGNALS_BEGIN_LINE, signals.source_code.get_slice_count("\n")):
		if signals.source_code.get_slice("\n", i).match("signal %s(*)" % function_name):
			function.signal_line = i
			break
	
	return function


static func get_function_list() -> PackedStringArray:
	var effects := Effects as GDScript
	return Array(effects.source_code.split("\n\nstatic func ").slice(1)).map(func(a: String) -> String:
		return a.get_slice("(", 0)
	)


static func is_effects_file_open() -> bool:
	return Effects in EditorInterface.get_script_editor().get_open_scripts()


static func is_effect_signals_file_open() -> bool:
	return __EffectSignals in EditorInterface.get_script_editor().get_open_scripts()


class Function:
	var name := "" :
		set(value):
			name = value
			name_changed.emit(value)
	var arguments: Array[Argument] = []
	var return_type := -1 :
		set(value):
			return_type = value
			return_type_changed.emit(value)
	var return_type_name := &"" :
		set(value):
			return_type_name = value
			return_type_name_changed.emit(value)
	var begin_line_index := -1
	var signal_line := -1
	var description := ""
	
	signal name_changed(new_name: String)
	signal return_type_changed(new_return_type: int)
	signal return_type_name_changed(new_return_type_name: StringName)
	signal argument_added(argument: Argument)
	
	func add_argument(arg_name: String) -> Argument:
		var argument := Argument.new(self)
		argument.set_name(arg_name)
		arguments.append(argument)
		argument_added.emit(argument)
		return argument
	
	
	func get_argument(index: int) -> Argument:
		if index < -arguments.size() or index >= arguments.size():
			return null
		return arguments[index]
	
	
	func set_name(value: String) -> Function:
		name = value
		return self
	
	
	func save() -> void:
		if __EffectsFileManager.is_effects_file_open():
			push_error("Could not save function %s since Effects.gd is open. Please close the file and try again." % name)
			return
		if __EffectsFileManager.is_effect_signals_file_open():
			push_error("Could not save function %s since EffectSignals.gd is open. Please close the file and try again." % name)
			return
		
		var effects := Effects as GDScript
		
		if begin_line_index < 0:
			begin_line_index = effects.source_code.count("\n") + 2
			effects.source_code += "\n\n" + get_header() + "\n" + get_body()
		else:
			var current_text := effects.source_code.get_slice("\n", begin_line_index)
			for i in range(begin_line_index + 1, effects.source_code.count("\n")):
				var line := effects.source_code.get_slice("\n", i)
				if not line.begins_with("\t"):
					break
				current_text += "\n" + line
			
			effects.source_code = effects.source_code.replace(current_text, get_header() + "\n" + get_body())
			
			#effects.source_code = effects.source_code.replace(effects.source_code.get_slice("\n", begin_line_index), "static func %s(%s) -> %s:%s" % [
				#name,
				#", ".join(arguments.map(func(a: Argument) -> String: return a.to_string())),
				#get_return_string(),
				#"" if description.is_empty() else " ## " + description.replace("\n", "[br]"),
			#]).replace(effects.source_code.get_slice("\n", begin_line_index + 1), "\tSignals.%s.emit(%s)" % [
				#name,
				#", ".join(arguments.map(func(a: Argument) -> String: return a.name))
			#])
		
		if not effects.source_code.ends_with("\n"):
			effects.source_code += "\n"
		
		effects.reload()
		ResourceSaver.save(effects)
		
		var signals := __EffectSignals as GDScript
		
		if signal_line < 0:
			signal_line = signals.source_code.count("\n")
			signals.source_code += "@warning_ignore(\"unused_signal\") signal %s(%s)\n" % [
				name,
				", ".join(arguments.map(func(a: Argument) -> String: return a.to_string_no_default()))
			]
		else:
			signals.source_code = signals.source_code.replace(signals.source_code.get_slice("\n", signal_line), "@warning_ignore(\"unused_signal\") signal %s(%s)" % [
				name,
				", ".join(arguments.map(func(a: Argument) -> String: return a.to_string_no_default()))
			])
		
		signals.reload()
		ResourceSaver.save(signals)
	
	
	func allows_default(arg_index: int) -> bool:
		return arg_index == arguments.size() - 1 or arguments[arg_index + 1].has_default
	
	
	func add_argument_from_string(arg_string: String) -> void:
		arguments.append(Argument.create_from_string(arg_string, self))
	
	
	func get_header() -> String:
		return "static func %s(%s) -> %s:%s" % [
			name,
			", ".join(arguments.map(func(a: Argument) -> String: return a.to_string())),
			get_return_string(),
			"" if description.is_empty() else " ## " + description.replace("\n", "[br]")
		]
	
	
	func get_body() -> String:
		if return_type == -1:
			return "\tEffectManager.propagate(MutableSignals.%s, [%s])\n\tEffectManager.propagate(Signals.%s, [%s])" % [
				name,
				", ".join(arguments.map(func(a: Argument) -> String: return a.name)),
				name,
				", ".join(arguments.map(func(a: Argument) -> String: return a.name))
			]
		
		if arguments.is_empty():
			push_warning("Effect %s returns a non-void value but it has no argument to return." % name)
			return "\tEffectManager.propagate(MutableSignals.%s, [])\n\tEffectManager.propagate(Signals.%s, [])\n\treturn " % [name, name] + ("null" if return_type == TYPE_OBJECT else (type_string(return_type) + "()"))
		
		return "\t%s = EffectManager.propagate(MutableSignals.%s, [%s], 0)\n\tEffectManager.propagate(Signals.%s, [%s])\n\treturn %s" % [
			get_argument(0).name,
			name,
			", ".join(arguments.map(func(a: Argument) -> String: return a.name)),
			name,
			", ".join(arguments.map(func(a: Argument) -> String: return a.name)),
			get_argument(0).name
		]
	
	
	func get_return_string() -> String:
		match return_type:
			-1:
				return "void"
			TYPE_NIL:
				return "Variant"
			TYPE_OBJECT:
				return return_type_name
			_:
				return type_string(return_type)
	
	
	static func create_new(function_name: String) -> Function:
		var function := Function.new()
		function.name = function_name
		return function
	
	
	static func create_from_line(line: int, _signal_line: int) -> Function:
		var effects := Effects as GDScript
		
		var begin_line := effects.source_code.get_slice("\n", line).trim_prefix("static func ")
		
		var function := Function.new()
		function.name = begin_line.get_slice("(", 0)
		function.begin_line_index = line
		function.signal_line = _signal_line
		if " ## " in begin_line:
			function.description = begin_line.get_slice(" ## ", 1).replace("[br]", "\n")
		
		var return_type_string := begin_line.get_slice(" -> ", 1).get_slice(":", 0)
		
		match return_type_string:
			"void":
				function.return_type = -1
			"Variant":
				function.return_type = TYPE_NIL
			_:
				function.return_type_name = return_type_string
				
				for t in TYPE_MAX:
					if type_string(t) == return_type_string:
						function.return_type = t as Variant.Type
						break
				
				if function.return_type == -1:
					function.return_type = TYPE_OBJECT
		
		var arg_string := ""
		for i in range(begin_line.find("(") + 1, begin_line.rfind(")")):
			match begin_line[i]:
				"," when arg_string.count("(") != arg_string.count(")"):
					arg_string += begin_line[i]
				",":
					function.add_argument_from_string(arg_string.strip_edges())
					arg_string = ""
				_:
					arg_string += begin_line[i]
		
		if not arg_string.is_empty():
			function.add_argument_from_string(arg_string.strip_edges())
		
		return function
	
	
	func _to_string() -> String:
		return "EffectFunction::" + name + "(" + ", ".join(arguments.map(func(a: Argument) -> String: return a.name)) + ")"
	
	
	class Argument:
		var name := "" :
			set(value):
				name = value
				name_changed.emit(value)
		var type := TYPE_NIL :
			set(value):
				type = value
				type_changed.emit(value)
		var type_name := "" :
			set(value):
				type_name = value
				type_name_changed.emit(value)
		var has_default := false :
			set(value):
				has_default = value
				
				has_default_changed.emit(value)
		var default: Variant = null :
			set(value):
				default = value
				default_changed.emit(value)
		
		var function: WeakRef
		
		signal name_changed(value: String)
		signal type_changed(value: Variant.Type)
		signal type_name_changed(value: String)
		signal has_default_changed(value: bool)
		signal default_changed(value: Variant)
		signal deleted()
		
		
		func _init(_function: Function) -> void:
			function = weakref(_function)
		
		
		func set_name(value: String) -> Argument:
			assert(value.is_valid_identifier())
			
			var base_name := value
			var suffix := 2
			
			if value[-1].is_valid_int():
				for i in range(value.length() - 1, -1, -1):
					if not value[i].is_valid_int():
						base_name = value.substr(0, i + 1)
						suffix = value.substr(i + 1).to_int()
						break
			
			var new_name := base_name
			while get_function().arguments.any(func(a: Argument) -> bool: return a != self and a.name == new_name):
				new_name = base_name + str(suffix)
				suffix += 1
			
			name = new_name
			return self
		
		
		func get_function() -> Function:
			return function.get_ref()
		
		
		func save() -> void:
			get_function().save()
		
		
		# note that get_function() still returns the function this argument was in
		# this can be used to save the function after deleting the argument
		func delete() -> void:
			get_function().arguments.erase(self)
			deleted.emit()
		
		
		func allows_default() -> bool:
			return get_function().allows_default(get_function().arguments.find(self))
		
		
		func get_next_argument() -> Argument:
			if get_function().get_argument(-1) == self:
				await get_function().argument_added
				return get_function().get_argument(-1)
			assert(self in get_function().arguments, "This argument was not found in its function.")
			return get_function().get_argument(get_function().arguments.find(self) + 1)
		
		
		func get_type_string() -> String:
			match type:
				TYPE_NIL:
					return "Variant"
				TYPE_OBJECT:
					return type_name
				_:
					return type_string(type)
		
		
		func get_default_string() -> String:
			if type == TYPE_NIL:
				return "null"
			
			match type:
				TYPE_BOOL:
					return str(default)
				TYPE_INT:
					return str(default)
				TYPE_FLOAT:
					var string := str(default)
					if not "." in string:
						string += ".0"
					return string
			
			if default == type_convert(null, type):
				if type == TYPE_OBJECT:
					return "null"
				return type_string(type) + "()"
			
			match type:
				TYPE_OBJECT:
					if is_instance_valid(default):
						push_error("Cannot convert non-null Object to String.")
						return ""
					return "null"
				TYPE_TRANSFORM2D:
					return "Transform2D(Vector2(%s, %s), Vector2(%s, %s), Vector2(%s, %s))" % [
						default.x.x, default.x.y, default.y.x, default.y.y, default.origin.x, default.origin.y
					]
			
			return var_to_str(default)
		
		
		func reset_default() -> void:
			default = get_base_value()
		
		
		func get_base_value() -> Variant:
			match type:
				TYPE_NIL, TYPE_OBJECT:
					return null
				_:
					return type_convert(null, type)
		
		
		func _to_string() -> String:
			if has_default:
				return "%s: %s = %s" % [name, get_type_string(), get_default_string()]
			return to_string_no_default()
		
		
		func to_string_no_default() -> String:
			return "%s: %s" % [name, get_type_string()]
		
		
		static func create_from_string(arg_string: String, _function: Function) -> Argument:
			var argument := Argument.new(_function)
			
			argument.name = arg_string.get_slice(":", 0)
			argument.type_name = arg_string.get_slice(": ", 1).get_slice(" = ", 0)
			for t in TYPE_MAX:
				if type_string(t) == argument.type_name:
					argument.type = t as Variant.Type
					break
			
			if argument.type == TYPE_NIL and argument.type_name != "Variant":
				argument.type = TYPE_OBJECT
			
			if "=" in arg_string:
				argument.has_default = true
				
				var default_string := arg_string.get_slice(" = ", 1)
				
				var expr := Expression.new()
				var parse_err := expr.parse(default_string)
				if parse_err:
					push_error("Could not parse the value of default value '%s': %s." % [default_string, expr.get_error_text()])
				else:
					var value = expr.execute([], Effects)
					if expr.has_execute_failed():
						push_error("Could not execute the value of default value '%s': %s." % [default_string, expr.get_error_text()])
					else:
						argument.default = value
			
			return argument
