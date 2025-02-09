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
- File names are in `PascalCase`, variable and function names in `snake_case` and constant names in `UPPER_SNAKE_CASE`.
- The project has some script templates to quickly get you started. When creating a script, use `Full Example Template` to see how your file should be structured.
- Simply look at existing files and mimic their structure and conventions and you're probably doing things right.
- Everything should **always** be statically typed, either by using `var my_variable := 0` (note the `:=`) or `var my_variable: Array[Dictionary] = []`. This should also be done in a `for` loop if Godot can't figure out the type by itself (such as when iterating over an untyped `Array` or over `Dictionary` keys).
This is probably enough to be able to start writing code. If you're ever confused about any conventions, feel free to read the rest of this style guide then.

## Filesystem

First, let's go over the project's filesystem. In the root directory, we have the following directories:

### Assets
This directory contains all files found in the `assets` directory in your local DemonCrawl installation, as well as some more assets extracted from the game's `data.win` file, as well as resources (like items or loot tables) and some scripts (like mastery scripts and item scripts). There are some more miscellaneous files found in here, when they make sense to go there.

### Resources
This directory contains various resources that are often reused. Most files are scripts that are written for very general situations. All resources are divided into 6 directories. When creating a new file that can be used more often than the one time it is created for, it should go in a fitting subdirectory:
#### Resources/DataContainers
All scripts in here inherit from `Resource` and its instances are used to store data. For example, `Quest` can store various data about a quest, like the quest's stages and the player's lives.
#### Resources/HelperObjects
All scripts in here are not directly used to store data but are instead generalized objects to make a specific thing easier to do. For example, `AnnotatedTexture` allows you to make a texture that can show a tooltip.
#### Resources/Scenes
This directory contains scenes (and their root scripts). It is similar to [UtilityNode](#utilitynode), but used for more complex nodes that require a scene.
#### Resources/Shaders
This directory contains all shaders used in the game.
#### Resources/Singletons
This directory contains all of the game's Singletons. A singleton is an object that is globally accessible. It is either an autoload, where the scene instance is globally accessible under its name, or a script, where the class name can be used to call all needed functions. For example, `ChestPopup` can be used anywhere using `ChestPopup.show_rewards()`.
#### Resources/UtilityNode
This directory contains generalized scripts of Nodes that can be directly created anywhere and have a specific purpose. For example, `FocusGrabber` can be created as a child of a `Control` to move the focus to the control when it is clicked.

### Scenes
This directory contains all of the game's scenes that are placed as the root of the scene tree. Each scene has its own separate directory. Each scene's directory also contains all of the scenes files that should not be used outside of the scene. If a scene's file is ever used outside of the scene, it should be moved into the [Resources](#resources) directory since it can be used generally.

### addons
This directory contains the project's addons (also known as plugins). Each addon has its own directory, and no file here should be edited, created, or deleted without first mentioning it to me (@elmarhoppieland). Each addon is made very generally and explained as documentation in the main script (named the same as the addon).

### EffectManager
This is a directory created by the `EffectManager` plugin to handle various effects. The 2 files here usually don't need to be edited and should instead be edited via the `EffectManager` tab in the top bar in the editor.

### Other Directories
The other directories (`script_templates`, `.data`, `.docs`, `.git` and `.godot`) are used for internal features and can almost always be ignored. They are also invisible in the editor.

### Miscellaneous Files
Some files are not placed in a specific directory. In the root directory, all files need to be here. In the `Resources` directory, the miscellaneous files should be moved in a fitting subdirectory. This is still a work-in-progress.
Files should never be created outside a fitting directory.

## Naming Conventions

Now, let's go over the project's naming conventions. Most importantly, everything should be named in a way that describes what it is for. A descriptive name is more important than a short one.

Casing should be done in the following way:

||Casing|Notes|
|--|--|--|
|File|`PascalCase.extension`|For scripts, should be the same as the class.|
|Class|`PascalCase`|Should be the same as the file name.|
|Constant|`UPPPER_SNAKE_CASE`||
|Variable|`snake_case`||
|Method|`snake_case()`||
|Signal|`snake_case()`|The `()` is technically optional if the signal doesn't have arguments, but should be added anyway.|

**Note:** This casing convention differs slightly from the global Godot style guide, since files are recommended to be cased in `snake_case`. We use `PascalCase` because that makes the script's file name the same as the class name.

### Private members

A script may use functions, variables or constants that should not be used outside the script. Godot doesn't provide a way to actually private a member, but we can prefix the function, variable or constant with an underscore (`_`) to indicate that is should not be used outside the script. This should be used whenever it doesn't make sense to use a member externally.

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

## Miscellaneous

One last thing to mention is that everything, unless impossible, should **always** be statically typed. This has 2 main advantages: 1) The game will run slightly faster, but more importantly, 2) Godot will have more and better autocomplete as well as be able to catch some errors more easily (like when misspelling a variable name).