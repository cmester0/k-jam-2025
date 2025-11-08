extends "res://scripts/base_desktop.gd"
# Example: Simple desktop application without mini-game
# This demonstrates how to extend base_desktop.gd for other applications

func _ready() -> void:
	super._ready()  # Call base desktop setup
	
	# Add your custom application windows or features here
	_create_example_window()


func _create_example_window() -> void:
	var example_window := create_window("Example App", Vector2(100, 100), Vector2(400, 300), true)
	
	var content_area := find_child_by_name(example_window, "content")
	if not content_area:
		return
	
	var label := Label.new()
	label.text = "This is an example desktop application.\n\nYou can extend base_desktop.gd to create any kind of\ncomputer interface without the folder race mini-game."
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_area.add_child(label)
	
	add_child(example_window)
	bring_to_front(example_window)
