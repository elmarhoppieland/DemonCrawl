# DemonCrawl Style Guide

This page will guide new contributors write code in a way similar to existing code in this project. If you plan on contributing, you should read this file before writing any code.

Most contributors likely only need to edit files, in which case only reading the [Summary](#summary) is probably enough to understand the project's conventions.

## Table of Contents

- [Summary](#summary)
- [Filesystem](#filesystem)
- [Naming Conventions](#naming-conventions)
- [Script Templates](#script-templates)
- [File Structure](#file-structure)
- [Miscellaneous](#miscellaneous)

## Summary

If you're just starting out, there's a good chance you only need to edit scripts and don't need to create any new ones. If that is the case, you probably don't need to read through this entire file, but can instead just mimic the rest of the script. Here are some general conventions that you should know about:
- File names, variable names, and function names are in `snake_case`. Constant names are in `CONSTANT_CASE`.
- Node names are in `PascalCase`.
- The project has some script templates to quickly get you started. I recommend creating your first script using the `Full Example Template` to see how your file should be structured.
- Simply look at existing files and mimic their structure and conventions and you're probably doing things right.
- Everything should **always** be statically typed, either by using `var my_variable := 0` (note the `:=`) or `var my_variable: Array[Dictionary] = []`. This should also be done in a `for` loop if Godot can't figure out the type by itself (such as when iterating over an untyped `Array` or over an untyped `Dictionary`'s keys).
- If a variable cannot be statically typed, it does not need to be typed as `Variant`. Instead, simply write `var my_variable = (...)`. If a function argument or return value cannot be statically typed, it _should_ be typed as `Variant`. For example, `func my_func(argument: Variant) -> Variant`.

This is probably enough to be able to start writing code. If you're ever confused about any conventions, feel free to read the rest of this style guide then.

## Filesystem

First, let's go over the project's filesystem. You should read this if you are unsure where to place a file.

In the root directory, we have the following directories:

### res://assets
This directory contains all files found in the `assets` directory in your local DemonCrawl installation, as well as some more assets extracted from the game's `data.win` file, as well as resources (like items or loot tables) and some scripts (like mastery scripts and item scripts). There are some more miscellaneous files found in here, when they make sense to go there.

As a rule of thumb, every directory and file in `res://assets` should be safely removable, unless it has another file in `res://assets` that depends on it. Files in `res://engine` should not depend on files in `res://assets` (though this rule is sometimes broken).

### res://engine
This directory contains all files that are necessary for the game to run. All files may depend on files in `res://engine`, and its files may not be easily removable.

### res://addons
This directory contains the project's addons (also known as plugins). Each addon has its own directory, and no file here should be edited, created, or deleted without mentioning it in the pr. Each addon is made very generically and documented in the main script (named the same as the addon).

### Other Directories
The other directories (`script_templates`, `.data`, `.docs`, `.git` and `.godot`) are used for internal features and can almost always be ignored. They are also invisible in the editor.

## Naming Conventions

Now, let's go over the project's naming conventions. Most importantly, everything should be named in a way that describes what it is for. A descriptive name is more important than a short one.

Casing should be done in the following way:

||Casing|Notes|
|--|--|--|
|File|`snake_case.extension`|For scripts, should be the same as the class (converted to snake case).|
|Class|`PascalCase`|Should be the same as the file name (converted to pascal case).|
|Constant|`CONSTANT_CASE`||
|Variable|`snake_case`||
|Method|`snake_case()`||
|Signal|`snake_case()`|The `()` is technically optional if the signal doesn't have arguments, but should be added anyway.|

### Private members

A script may use functions, variables or constants that should not be used outside the script. Godot doesn't provide a way to actually private a member, but we can prefix the function, variable or constant with an underscore (`_`) to indicate that is should not be used outside the script. This should be used whenever it doesn't make sense to use a member externally. A getter or setter function (`get_*()` and `set_*()`) may be added if the variable is private but should be settable/gettable publicly.

### Virtual Methods

Godot's virtual methods are, like our private methods, prefixed with an underscore (`_`). This doesn't create confusion because virtual methods should also never be called externally. We use the same convention whenever a method is intended to be overridden, in which case the method's documentation should clearly mention that it is a virtual method.

## Script Templates

Before moving on to each script's file structure, it is first important to mention that the project has script templates set-up to make it easier to write code using the projects file structure conventions, without even having to fully read this style guide! When creating a script, select the template `Full Example Template` and all the important parts of the script will be created automatically.

Other useful templates are `Named` and `Named Tool`, which both have anonymous alternatives that don't have a class name. These will create a nearly empty file that allow you to get started immediately.

## File Structure

This part is probably the most important part to get right, as the project will turn into a mess if everyone uses a different file structure. All script files should be formatted in the following way:

```gdscript
extends BaseScript
class_name MyClass # not all scripts need a class, but most should have one

# ==============================================================================
# all of the script's constants go here.
const MY_CONST := "A commonly used string."
const MY_OTHER_CONST := -1
# ==============================================================================
# all static variables go here.
static var my_static_variable := 3
# ==============================================================================
# all exported variables go here.
@export var my_export_variable := 0.1
# ==============================================================================
# all normal variables go here.
var my_normal_variable: Array[Dictionary] = []
# ==============================================================================
# all onready variables go here.
@onready var my_onready_variable ## Variable documentation.
# ==============================================================================
# all signals go here.
signal my_signal() ## Signal documentation.
# ==============================================================================

func _init(parameter: Dictionary) -> void:
	my_normal_variable.append(parameter)


static func my_static_function() -> MyClass:
	var local_variable := MyClass.new({})
	return local_variable


## Function documentation.
func my_normal_function() -> int:
	return MY_CONST.to_int() + 1

```
As you can see, `extends` should go on the first line, and `class_name` should go on the second, if the script has one. Almost all scripts should have a class name to make it easy to access it.
We add one blank line in-between the `class_name` and the variables.
Types of variables are separated using exactly 78 `=` symbols. This can just be copy-pasted from another line in the same file. New files created with a script template will already have this.
After the variables, we add one blank line before all the script's functions.
The order of the functions doesn't matter, but functions should be separated using 2 empty lines. This separation excludes documentation placed above the function.

## Static Typing

Godot offer dynamic typing, which means that a variable can first be assigned one type of value and then another. This can be useful, but has a few drawbacks:
- The game will perform slightly slower
- Autocomplete may not always work
- `Ctrl`-clicking a variable or function may not take you to its definition or documentation.

Godot also offers static typing, to enforce a specific type of value in a variable. Doing this will create a performance boost, but more importantly, Godot will be able to more easily catch errors. Therefore, we **always** statically type variables and functions.

Godot allows for two ways to statically type a variable:
```gdscript
var my_var_explicit: int = 0
var my_var_inferred := 0
```
When possible, variables types should be _inferred_, which means that Godot will deduce the type of the variable. If Godot cannot deduce the variable's type, we either write the type explicitly or use `as`:
```gdscript
var my_var := (...) as int
```

Functions should be statically typed like this:
```gdscript
func my_func(argument: int, default_argument: Vector2 = Vector2.ZERO) -> String:
    (...)
```

We should also statically type our `Arrays` and `Dictionaries`, as follows:
```gdscript
var array: Array[Resource] = []
var dictionary: Dictionary[int, String] = []
```
Note that Godot does not support nested types, so an `Array` of `Dictionaries` cannot be further statically typed.

If a variable, `Array` or `Dictionary` _cannot_ be statically typed, we omit the type entirely:
```gdscript
var my_var = (...)
var array := []
var dict := {}
```

If a function cannot be statically typed, we write `Variant`:
```gdscript
func my_func(argument: Variant, default: Array = []) -> Variant:
    (...)
```
