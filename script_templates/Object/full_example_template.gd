extends _BASE_
class_name _CLASS_

## A short description of the class (optional).
##
## An extended description of the class (optional).
## This documentation can be found by pressing F1 and searching for '_CLASS_'.
## [br][br]
## [b]Important note:[/b] All variables, constants and methods should always be typed (unless not possible).

# ==============================================================================
# all constants go here.
const MY_CONSTANT := "A commonly used string." ## This constant's documentation (can be found by pressing F1 and searching for '_CLASS_').
# ==============================================================================
# all enums (enumerations) go here.
# all enums should be named, so we can use static typing on them.
enum Enumeration {
	ENUM_A,
	ENUM_B
}
# ==============================================================================
# all static variables go here.
# note that variables should only be static if they have a reason to be.
static var my_static_variable := Enumeration.ENUM_A
# ==============================================================================
# all @export variables should go here.
# any other @export-like annotations should also go here (e.g. @export_multiline or @export_group).
@export var my_exported_variable := Vector2(2, 1.5)
# ==============================================================================
# all normal variables should go here.
var my_normal_variable := ""
var my_array_variable: Array[Dictionary] = [] ## Arrays that only hold one type of variable should also be typed.

var _my_private_variable := PI
# ==============================================================================
# all @onready variables go here.
# most @onready variables can be private and should therefore be prefixed with an underscore.
# note that @onready only works for Node-derived classes.
@onready var _my_onready_variable: Node = $Path/To/Child
@onready var _my_other_onready_variable: _CLASS_ = %UniqueNameInScene
# ==============================================================================
# all signals go here.
signal my_signal()
signal my_signal_with_arguments(argument: int)
# ==============================================================================

func _init(argument: String = MY_CONSTANT) -> void:
	my_normal_variable = argument


## Function documentation should go on the line(s) above the function.
## It is not required but is encouraged.
static func create() -> _CLASS_:
	var my_local_variable := _CLASS_.new()
	return my_local_variable


func _private_function() -> String:
	return MY_CONSTANT + my_normal_variable


## A virtual method's documentation should clearly state that the method is virtual.
func _virtual_method() -> void:
	pass
