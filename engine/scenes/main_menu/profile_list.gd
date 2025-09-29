extends MarginContainer
class_name ProfileList

# ==============================================================================
static var selected_profile: String = Eternal.create("", "settings") :
	set(value):
		selected_profile = value
# ==============================================================================
var selected_page: Page
# ==============================================================================

func _ready() -> void:
	visibility_changed.connect(func():
		if not visible:
			return
		
		for page: Page in get_children():
			page.queue_free()
		
		await get_tree().process_frame
		
		const DIR := "user://saves/"
		const MAX_PAGE_SIZE := 6
		
		if not DirAccess.dir_exists_absolute(DIR):
			DirAccess.make_dir_absolute(DIR)
		
		var page := Page.new()
		add_child(page)
		selected_page = page
		for file in DirAccess.get_files_at(DIR):
			var path := DIR.path_join(file)
			
			var avatar_atlas_position: Vector2i = Eternity.get_saved_value(path, Avatar, "atlas_position")
			var level: int = Eternity.get_saved_value(path, XPBar, "level")
			var profile_name := file.get_basename()
			
			var profile := MainMenuProfile.create(profile_name, avatar_atlas_position, level)
			
			page.add_child(profile)
			
			if page.get_child_count() >= MAX_PAGE_SIZE:
				var new_page := Page.new()
				page.next = new_page
				new_page.prev = page
				add_child(new_page)
				page = new_page
				new_page.modulate.a = 0
			
			profile.selected.connect(func():
				ProfileList.selected_profile = profile_name
				get_tree().change_scene_to_file("res://engine/scenes/main_menu/main_menu.tscn")
			)
		
		var create_profile := MainMenuProfile.create("Create Profile", Vector2i.ZERO, -1)
		page.add_child(create_profile)
		create_profile.selected.connect(func():
			ProfileList.selected_profile = ""
			get_tree().change_scene_to_file("res://engine/scenes/main_menu/main_menu.tscn")
		)
	)


func change_page(direction: ChangePageButton.Direction) -> void:
	selected_page = selected_page.change_page(direction)


class Page extends VBoxContainer:
	var prev: Page
	var next: Page
	
	func change_page(direction: ChangePageButton.Direction) -> Page:
		var new_page := next if direction > 0 else prev
		if new_page:
			modulate.a = 0
			new_page.modulate.a = 1
			return new_page
		return self
