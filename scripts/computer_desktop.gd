extends Control

const TARGET_FILE := "Wells_Report.docx"
const TARGET_PATH := ["Projects", "Client_Phoenix", "Quarterly", "Drafts"]
const MAX_FOLDERS := 67
const EXIT_SCENE_PATH := "res://node_3d.tscn"

var folder_tree: Dictionary
var mail_window: PanelContainer
var mail_message_window: PanelContainer
var mail_message_label: RichTextLabel
var mail_message_base_text: String = ""
var mission_timer: Timer
var mission_started: bool = false
var mission_completed: bool = false
var mission_failed: bool = false
var countdown_remaining: int = 0
const MISSION_DURATION_SECONDS := 300  # 5 minutes
var send_prompt_window: PanelContainer
var file_icon_texture: Texture2D
@onready var cursor: Sprite2D
var open_windows: Dictionary = {}
var desktop_container: Control


func _ready() -> void:
	# Hide the OS cursor so we can use our own
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	_create_background()
	_create_top_bar()
	_create_taskbar()
	_create_mail_window()
	_create_notes_window()

	# Create a dedicated desktop container for icons so we can manage them cleanly
	desktop_container = Control.new()
	desktop_container.name = "desktop_container"
	desktop_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desktop_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(desktop_container)
	_generate_folder_tree()
	_show_desktop_folders(folder_tree["Desktop"], Vector2(80, 100))
	
	# Cleanup any stray top-level folder icons left from earlier edits/runs
	_cleanup_orphan_icons()
	_create_exit_button()
	
	# Create cursor last to ensure it's on top
	_create_cursor()
	
	# Schedule the new mail notification to appear after a short delay
	var timer := get_tree().create_timer(3.0)  # 3 second delay
	timer.timeout.connect(func(): 
		_trigger_new_mail()
		# Optional: Add a notification sound here
	)


# --- ENVIRONMENT SETUP ---

func _create_background() -> void:
	var bg := TextureRect.new()
	var wallpaper: Texture = load("res://textures/desktopwallpaper.jpg") as Texture
	if wallpaper:
		bg.texture = wallpaper
	else:
		push_error("Failed to load wallpaper texture!")
		bg.color = Color(0.1, 0.1, 0.2)  # Fallback color if texture fails to load
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.custom_minimum_size = get_viewport_rect().size  # Ensure it fills the viewport
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(bg)
	bg.z_index = -1  # Make sure background stays in back


func _create_top_bar() -> void:
	var top_bar := ColorRect.new()
	top_bar.color = Color(0.05, 0.08, 0.12)
	top_bar.size = Vector2(get_viewport_rect().size.x, 40)
	add_child(top_bar)

	var apps_label := Label.new()
	apps_label.text = "APPLICATIONS"
	apps_label.position = Vector2(20, 10)
	apps_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1))
	top_bar.add_child(apps_label)

	var time_label := Label.new()
	time_label.text = "08:22"
	time_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.8))
	time_label.position = Vector2(get_viewport_rect().size.x - 80, 10)
	top_bar.add_child(time_label)


func _create_taskbar() -> void:
	var taskbar := ColorRect.new()
	taskbar.color = Color(0.03, 0.06, 0.1)
	taskbar.size = Vector2(get_viewport_rect().size.x, 35)
	taskbar.position.y = get_viewport_rect().size.y - 35
	add_child(taskbar)

	var task_label := Label.new()
	task_label.text = "FILE EXPLORER   |   MAIL   |   NOTES"
	task_label.position = Vector2(20, 8)
	task_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1))
	taskbar.add_child(task_label)


# --- WINDOWS ---

# Store mail states
var coworkers: Array = [
	{"name": "Alex Pendell", "title": "Project Manager", "status": "Online", "has_new_mail": false},
	{"name": "Sarah Chen", "title": "Software Developer", "status": "Away", "has_new_mail": false},
	{"name": "Marcus Johnson", "title": "UX Designer", "status": "Online", "has_new_mail": false},
	{"name": "Emma Williams", "title": "Product Owner", "status": "Offline", "has_new_mail": false}
]

func _create_mail_window() -> void:
	mail_window = _create_window("Mail", Vector2(get_viewport_rect().size.x - 500, 50), Vector2(450, 300))
	_show_mail_contacts()  # Start by showing contacts instead of direct message
	add_child(mail_window)

func _show_mail_contacts() -> void:
	var content_area = _find_child_by_name(mail_window, "content") if mail_window else null
	if content_area:
		# Clear existing content
		for child in content_area.get_children():
			child.queue_free()
		
		# Create a VBox for contacts
		var contact_list := VBoxContainer.new()
		contact_list.add_theme_constant_override("separation", 2)
		content_area.add_child(contact_list)
		
		# Add each coworker as a button
		for coworker in coworkers:
			var contact_button := Button.new()
			contact_button.flat = true
			contact_button.custom_minimum_size = Vector2(420, 50)
			
			# Create a horizontal layout for contact info
			var hbox := HBoxContainer.new()
			contact_button.add_child(hbox)
			
			# Status indicator
			var status := ColorRect.new()
			status.custom_minimum_size = Vector2(8, 8)
			status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			match coworker.status:
				"Online": status.color = Color(0.2, 0.9, 0.2)  # Green
				"Away": status.color = Color(0.9, 0.9, 0.2)    # Yellow
				"Offline": status.color = Color(0.5, 0.5, 0.5)  # Gray
			
			var status_container := CenterContainer.new()
			status_container.custom_minimum_size = Vector2(30, 50)
			status_container.add_child(status)
			hbox.add_child(status_container)
			
			# Contact info (name and title)
			var info := VBoxContainer.new()
			info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_label := Label.new()
			name_label.text = coworker.name
			name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
			info.add_child(name_label)
			
			var title_label := Label.new()
			title_label.text = coworker.title
			title_label.add_theme_font_size_override("font_size", 10)
			title_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			info.add_child(title_label)
			
			hbox.add_child(info)
			
			# Notification indicator
			if coworker.has_new_mail:
				var notif := ColorRect.new()
				notif.color = Color(0.9, 0.2, 0.2)  # Red dot
				notif.custom_minimum_size = Vector2(8, 8)
				notif.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				
				var notif_container := CenterContainer.new()
				notif_container.custom_minimum_size = Vector2(30, 50)
				notif_container.add_child(notif)
				hbox.add_child(notif_container)
			
			contact_list.add_child(contact_button)
			
			# Connect the button click
			contact_button.connect("pressed", Callable(self, "_on_contact_clicked").bind(coworker.name))

func _on_contact_clicked(contact_name: String) -> void:
	if contact_name == "Alex Pendell":
		var urgent_text := "[b]From:[/b] Alex Pendell\n[b]Subject:[/b] URGENT: Missing report\n\nI need the [color=yellow]%s[/color] in the next five minutes. If I don't have it, I'm filing a complaint with the boss. Hop to it!".format([TARGET_FILE])
		_show_mail_message(urgent_text, true)
		# Update coworker status to show message read
		var updated := false
		for coworker in coworkers:
			if coworker.name == "Alex Pendell":
				coworker.has_new_mail = false
				updated = true
				break
		if updated:
			_show_mail_contacts()
		if not mission_started and not mission_completed and not mission_failed:
			_start_mission_countdown()

func _trigger_new_mail() -> void:
	# Find Alex and set new mail
	for coworker in coworkers:
		if coworker.name == "Alex Pendell":
			coworker.has_new_mail = true
			_show_mail_contacts()  # Refresh the contact list to show notification
			mission_started = false
			mission_completed = false
			mission_failed = false
			countdown_remaining = MISSION_DURATION_SECONDS
			mail_message_base_text = ""
			if mission_timer:
				mission_timer.stop()
			_close_send_prompt()
			break

func _create_notes_window() -> void:
	var notes := _create_window("Notes", Vector2(get_viewport_rect().size.x - 500, 360), Vector2(400, 200))
	var content_area = _find_child_by_name(notes, "content")
	var text := TextEdit.new()
	text.text = "• Find missing file\n• Reply to Alex\n• Don't delete the wrong folder!"
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Use white text since we're on a dark background
	text.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	if content_area:
		content_area.add_child(text)
	else:
		notes.add_child(text)
	add_child(notes)


func _create_window(title: String, pos: Vector2, size: Vector2, is_dark: bool = false) -> PanelContainer:
	# Create the main window panel
	var panel := PanelContainer.new()
	panel.position = pos
	panel.custom_minimum_size = size

	# Create a VBox to hold header and content in proper order
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	# Window background style (content area)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_dark or title == "Mail" or title == "Notes":
		style.bg_color = Color(0.05, 0.08, 0.12) # Dark blue terminal color
		style.border_color = Color(0.15, 0.18, 0.25)
	else:
		style.bg_color = Color(0.96, 0.96, 0.96)
		style.border_color = Color(0.6, 0.6, 0.6)
	
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	panel.add_theme_stylebox_override("panel", style)

	# Title bar (header) - darker strip across the top that can be dragged
	var header_bar := ColorRect.new()
	header_bar.color = Color(0.12, 0.18, 0.25)
	header_bar.custom_minimum_size = Vector2(size.x, 30)
	header_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	vbox.add_child(header_bar)

	# Make header draggable
	header_bar.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				# Start dragging on mouse down, stop on mouse up
				if event.pressed:
					panel.set_meta("drag_offset", panel.get_global_mouse_position() - panel.position)
					panel.set_meta("is_dragging", true)
				else:
					panel.set_meta("is_dragging", false)
		elif event is InputEventMouseMotion:
			# Update window position while dragging
			if panel.get_meta("is_dragging", false):
				var drag_offset = panel.get_meta("drag_offset", Vector2.ZERO)
				panel.position = panel.get_global_mouse_position() - drag_offset
	)

	# Header layout: HBox to align title and close button
	var header_hbox := HBoxContainer.new()
	header_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.custom_minimum_size = Vector2(size.x, 30)
	# Make sure the HBox passes through mouse events to the header_bar
	header_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	header_bar.add_child(header_hbox)

	# Small spacer at the start for padding
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	header_hbox.add_child(spacer)

	# Title label on the header (left-aligned)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow dragging through the label
	header_hbox.add_child(title_label)

	# Close button on header (right)
	var header_close := Button.new()
	header_close.text = "X"
	header_close.custom_minimum_size = Vector2(22, 22)
	header_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	header_close.connect("pressed", Callable(self, "_close_window").bind(title))
	header_hbox.add_child(header_close)

	# Content container (where folder items / controls will be placed)
	var content := VBoxContainer.new()
	content.name = "content"
	content.custom_minimum_size = Vector2(size.x, max(0, size.y - 30))
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(content)

	# Set the dark theme metadata
	panel.set_meta("is_dark", is_dark or title == "Mail" or title == "Notes")

	return panel


func _show_mail_message(text: String, show_countdown: bool = false) -> void:
	# If message window exists, update it and bring to front
	if mail_message_window and is_instance_valid(mail_message_window):
		var existing_content = _find_child_by_name(mail_message_window, "content")
		if existing_content:
			for c in existing_content.get_children():
				if c is RichTextLabel:
					mail_message_label = c
					mail_message_label.bbcode_enabled = true
					if show_countdown:
						mail_message_base_text = text
						_update_mail_message_text()
					else:
						mail_message_label.text = text
					_bring_to_front(mail_message_window)
					return

	# Create a new message window
	var base_position := Vector2(120, 80)
	if mail_window and is_instance_valid(mail_window):
		base_position = mail_window.position + Vector2(50, 50)

	mail_message_window = _create_window(
		"New Message",
		base_position,
		Vector2(450, 300),
		true
	)

	var content_area = _find_child_by_name(mail_message_window, "content")
	if not content_area:
		content_area = mail_message_window

	mail_message_label = RichTextLabel.new()
	mail_message_label.bbcode_enabled = true
	mail_message_label.custom_minimum_size = Vector2(420, 260)
	mail_message_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	mail_message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mail_message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_area.add_child(mail_message_label)

	if show_countdown:
		mail_message_base_text = text
		_update_mail_message_text()
	else:
		mail_message_label.text = text

	add_child(mail_message_window)
	_bring_to_front(mail_message_window)


func _show_send_prompt() -> void:
	if mission_completed:
		_show_mail_message("[b]Alex Pendell:[/b]\nAlready got the file—thanks again!", false)
		return
	if mission_failed:
		_show_mail_message("[b]Alex Pendell:[/b]\nIt's too late—I'm already escalating this.", false)
		return

	if send_prompt_window and is_instance_valid(send_prompt_window):
		_bring_to_front(send_prompt_window)
		return

	var base_position := Vector2(180, 140)
	if mail_message_window and is_instance_valid(mail_message_window):
		base_position = mail_message_window.position + Vector2(30, 30)

	send_prompt_window = _create_window("Send File", base_position, Vector2(360, 220), true)
	var content_area := _find_child_by_name(send_prompt_window, "content")
	if not content_area:
		content_area = send_prompt_window

	var instructions := RichTextLabel.new()
	instructions.bbcode_enabled = true
	instructions.text = "You located [color=yellow]%s[/color]. Should I send it to Alex now?" % TARGET_FILE
	instructions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instructions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	instructions.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_area.add_child(instructions)

	var button_row := HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_theme_constant_override("separation", 8)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(spacer)

	var send_button := Button.new()
	send_button.text = "Send to Alex"
	send_button.connect("pressed", Callable(self, "_on_send_file_pressed"))
	button_row.add_child(send_button)

	var cancel_button := Button.new()
	cancel_button.text = "Cancel"
	cancel_button.connect("pressed", Callable(self, "_on_cancel_send_file"))
	button_row.add_child(cancel_button)

	content_area.add_child(button_row)

	add_child(send_prompt_window)
	_bring_to_front(send_prompt_window)


func _on_send_file_pressed() -> void:
	_show_mail_message("[b]From:[/b] Alex Pendell\n[b]Subject:[/b] Perfect timing\n\nThat was fast! I'm sending this up the chain right now. Appreciate it.", false)
	_complete_mission(true)
	_close_send_prompt()


func _on_cancel_send_file() -> void:
	_close_send_prompt()


func _close_send_prompt() -> void:
	if send_prompt_window and is_instance_valid(send_prompt_window):
		send_prompt_window.queue_free()
	send_prompt_window = null



func _update_mail_message_text() -> void:
	if not mail_message_label or mail_message_base_text == "":
		return
	var minutes := countdown_remaining / 60
	var seconds := countdown_remaining % 60
	var countdown_text := "%02d:%02d" % [minutes, seconds]
	if countdown_remaining <= 10:
		countdown_text = "[color=#ff4d4d]%s[/color]" % countdown_text
	var countdown_line := "\n\n[b]Time remaining:[/b] %s" % countdown_text
	mail_message_label.text = mail_message_base_text + countdown_line


func _start_mission_countdown() -> void:
	if mission_timer == null:
		mission_timer = Timer.new()
		mission_timer.wait_time = 1.0
		mission_timer.one_shot = false
		mission_timer.timeout.connect(Callable(self, "_on_mission_timer_timeout"))
		add_child(mission_timer)

	countdown_remaining = MISSION_DURATION_SECONDS
	mission_started = true
	mission_completed = false
	mission_failed = false
	mission_timer.start()
	_update_mail_message_text()


func _on_mission_timer_timeout() -> void:
	if mission_completed:
		mission_timer.stop()
		return

	countdown_remaining = max(countdown_remaining - 1, 0)
	_update_mail_message_text()

	if countdown_remaining <= 0:
		mission_timer.stop()
		mission_failed = true
		mission_started = false
		_handle_mission_failure()


func _complete_mission(success: bool) -> void:
	mission_completed = success
	mission_started = false
	mission_failed = not success
	if mission_timer:
		mission_timer.stop()
	_close_send_prompt()
	if success:
		mail_message_base_text = ""
	else:
		_handle_mission_failure()


func _handle_mission_failure() -> void:
	_close_send_prompt()
	mail_message_base_text = ""
	_show_mail_message("[b]From:[/b] Alex Pendell\n[b]Subject:[/b] Escalating to management\n\nYou missed the deadline. I'm looping in our boss. We'll talk about this later.")


# --- FOLDER GENERATION ---

func _generate_folder_tree() -> void:
	randomize()
	folder_tree = {"Desktop": {}}
	var desktop: Dictionary = folder_tree["Desktop"] as Dictionary

	# Add some decoy folders on the desktop
	for i in range(3):
		var decoy_name := _random_folder_name()
		while desktop.has(decoy_name):
			decoy_name = _random_folder_name()
		desktop[decoy_name] = _make_subfolders(0, 0)

	# Create the guaranteed path to the target file with additional decoys at each level
	var current: Dictionary = desktop
	for level in range(TARGET_PATH.size()):
		var folder: String = TARGET_PATH[level]
		if not current.has(folder):
			current[folder] = {}
		# Add sibling decoy folders at this level for misdirection
		var sibling_decoys: int = randi_range(1, 3)
		for _j in range(sibling_decoys):
			var sibling_name: String = _random_folder_name()
			while current.has(sibling_name):
				sibling_name = _random_folder_name()
			current[sibling_name] = _make_subfolders(level + 1, 0)
		current = current[folder] as Dictionary

	# Add extra folders inside the final target folder for more depth
	var internal_decoys: int = randi_range(2, 4)
	for _k in range(internal_decoys):
		var inner_name: String = _random_folder_name()
		while current.has(inner_name):
			inner_name = _random_folder_name()
		current[inner_name] = _make_subfolders(TARGET_PATH.size(), 0)

	# Place the target file at the end of the path
	current[TARGET_FILE] = null


func _make_subfolders(depth: int, counter: int) -> Dictionary:
	if depth > 3 or counter > MAX_FOLDERS:
		return {}
	var folder_count := randi_range(1, 4)
	var dict := {}
	for i in range(folder_count):
		dict[_random_folder_name()] = _make_subfolders(depth + 1, counter + 1)
	return dict


func _random_folder_name() -> String:
	var words = ["Backup", "Docs", "Old", "Temp", "Misc", "Cases", "Data", "Ref", "Work"]
	return words.pick_random() + "_" + str(randi_range(1, 999))


# --- DESKTOP DISPLAY ---

func _show_desktop_folders(tree: Dictionary, start_pos: Vector2) -> void:
	var x := start_pos.x
	var y := start_pos.y
	var spacing := 80  # spacing to fit icon + label comfortably

	for name: String in tree.keys():
		_create_folder_icon(name, Vector2(x, y), tree[name])
		y += spacing


func _create_folder_icon(name: String, pos: Vector2, content: Variant) -> void:
	# Build a compact, clickable folder icon with centered image above a label.
	var vbox := VBoxContainer.new()
	var container_size := Vector2(64, 80)
	vbox.position = pos
	vbox.custom_minimum_size = container_size

	# Center the icon area
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(container_size.x, 48)

	var folder := TextureButton.new()
	var icon_size := Vector2(40, 40) # slightly bigger icon
	folder.texture_normal = load("res://textures/folder_icon.png")
	folder.ignore_texture_size = true
	folder.custom_minimum_size = icon_size
	folder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	folder.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	center.add_child(folder)

	vbox.add_child(center)

	var label := Label.new()
	label.text = name
	label.custom_minimum_size = Vector2(container_size.x, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.7, 0.9, 1))
	label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(label)

	# Put desktop icons inside the desktop container so they don't clutter root
	if desktop_container:
		desktop_container.add_child(vbox)
	else:
		add_child(vbox)

	# Connect the folder button (only once)
	folder.connect("pressed", Callable(self, "_on_folder_opened").bind(name, content))


func _on_folder_opened(folder_name: String, content: Variant) -> void:
	# If this is the target file, show the send prompt window
	if folder_name == TARGET_FILE:
		if not mission_started:
			return
		_show_send_prompt()
		return

	if not (content is Dictionary):
		return

	# Don't reopen already open windows, just bring them to front
	if open_windows.has(folder_name):
		_bring_to_front(open_windows[folder_name])
		return

	var window := _create_window(
		folder_name,
		Vector2(
			randf_range(100, get_viewport_rect().size.x - 400),
			randf_range(100, get_viewport_rect().size.y - 300)
		),
		Vector2(350, 300),
		true
	)

	var content_area := _find_child_by_name(window, "content")
	if not content_area:
		content_area = window

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_area.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	var folder_dict: Dictionary = content
	for item_name in folder_dict.keys():
		var item_content = folder_dict[item_name]
		var icon := _create_window_folder_icon(item_name, item_content)
		grid.add_child(icon)

	add_child(window)
	open_windows[folder_name] = window


# --- CUSTOM CURSOR ---

func _create_cursor() -> void:
	cursor = Sprite2D.new()
	var texture_path := "res://textures/cursor.png"
	var cursor_tex: Texture2D = null
	if ResourceLoader.exists(texture_path):
		cursor_tex = load(texture_path) as Texture2D
	if cursor_tex:
		cursor.texture = cursor_tex
		cursor.scale = Vector2(0.5, 0.5)  # Make cursor smaller
	else:
		# Create a default cursor if texture fails to load
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		var tex := ImageTexture.create_from_image(img)
		cursor.texture = tex
	cursor.position = Vector2(100, 100)
	add_child(cursor)
	# Set z_index to the maximum allowed so the cursor stays above everything
	var max_z := RenderingServer.CANVAS_ITEM_Z_MAX
	cursor.z_index = max_z
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN  # Hide the system cursor
	
	# Ensure cursor node is the last child to maintain proper draw order
	move_child(cursor, get_child_count() - 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		cursor.position = event.position  # Update cursor position
		
	if event is InputEventMouseButton:
		if event.pressed:
			_handle_click(event.position)  # Handle mouse clicks

func _handle_click(click_pos: Vector2) -> void:
	# Remove this function as we're now using proper signal connections
	pass


func _process(delta: float) -> void:
	if cursor:
		cursor.global_position = get_viewport().get_mouse_position()
		var max_z := RenderingServer.CANVAS_ITEM_Z_MAX
		if cursor.z_index != max_z:
			cursor.z_index = max_z
		# Ensure cursor stays on top
		if cursor.get_index() != get_child_count() - 1:
			move_child(cursor, get_child_count() - 1)


# Helper function to check if a node is inside the desktop_container
func _is_in_desktop_container(node: Node) -> bool:
	var parent := node.get_parent()
	while parent:
		if parent == desktop_container:
			return true
		parent = parent.get_parent()
	return false

# Helper function to check if node has folder icon
func _has_folder_icon(node: Node) -> bool:
	if node is TextureButton:
		var tex: Texture2D = node.texture_normal
		return tex != null and tex.resource_path.find("folder_icon.png") != -1
	elif node is TextureRect:
		var tex: Texture2D = node.texture
		return tex != null and tex.resource_path.find("folder_icon.png") != -1
	return false

func _cleanup_orphan_icons() -> void:
	# Remove any folder icons that are not in the desktop_container
	var to_clean: Array[Node] = []
	
	# First collect nodes to avoid modifying during iteration
	# Use a queue to check all nodes in the scene
	var to_check: Array[Node] = [self]
	while not to_check.is_empty():
		var node: Node = to_check.pop_front() as Node
		
		# Skip if this is the desktop_container or its children
		if node == desktop_container or _is_in_desktop_container(node):
			continue
			
		# Check if this node has a folder icon
		if _has_folder_icon(node):
			to_clean.append(node)
		elif node is VBoxContainer or node is GridContainer:
			# Check container children that might be folder icon layouts
			for child in node.get_children():
				if child is CenterContainer or child is VBoxContainer:
					var has_icon := false
					for grandchild in child.get_children():
						if _has_folder_icon(grandchild):
							has_icon = true
							break
					if has_icon:
						to_clean.append(child)
		
		# Add children to the check queue
		to_check.append_array(node.get_children())
	
	# Now clean up all collected nodes
	for node in to_clean:
		node.queue_free()


func _bring_to_front(win: Node) -> void:
	# Bring a window to the front by setting its z_index higher than siblings
	if not (win and win is CanvasItem):
		return
	var parent = win.get_parent()
	if not parent:
		return
	var max_z := 0
	for c_base in parent.get_children():
		var c: CanvasItem = c_base as CanvasItem
		if c:
			max_z = max(max_z, c.z_index)
	var allowed_max: int = RenderingServer.CANVAS_ITEM_Z_MAX
	var next_z: int = min(max_z + 1, allowed_max)
	win.z_index = next_z
	
	# Ensure cursor stays above the newly frontmost window
	if cursor and is_instance_valid(cursor):
		cursor.z_index = allowed_max


func _find_child_by_name(root: Node, name: String) -> Node:
	# Initialize a default Node to return when no match is found
	var default_node: Node = null
	if not root:
		return default_node
	
	for child in root.get_children():
		if child.name == name:
			return child
		var res := _find_child_by_name(child, name)
		if res:
			return res
	
	return default_node


func _get_file_icon_texture() -> Texture2D:
	if file_icon_texture:
		return file_icon_texture

	var icon_path := "res://textures/file_icon.png"
	if ResourceLoader.exists(icon_path):
		var loaded := load(icon_path) as Texture2D
		if loaded:
			file_icon_texture = loaded
			return file_icon_texture

	var width := 40
	var height := 40
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var paper_color := Color(0.96, 0.97, 1.0)
	for x in range(4, width - 4):
		for y in range(4, height - 4):
			img.set_pixel(x, y, paper_color)

	var border_color := Color(0.2, 0.2, 0.35)
	for x in range(4, width - 4):
		img.set_pixel(x, 4, border_color)
		img.set_pixel(x, height - 5, border_color)
	for y in range(4, height - 4):
		img.set_pixel(4, y, border_color)
		img.set_pixel(width - 5, y, border_color)

	var fold_color := Color(0.9, 0.92, 0.99)
	for offset_y in range(4):
		for offset_x in range(offset_y + 1):
			img.set_pixel(width - 6 - offset_x, 4 + offset_y, fold_color)

	var header_color := Color(0.32, 0.5, 0.85)
	for x in range(6, width - 6):
		for y in range(6, 10):
			img.set_pixel(x, y, header_color)

	var line_color := Color(0.55, 0.65, 0.9)
	for i in range(3):
		var line_y := 12 + i * 6
		for x in range(7, width - 7):
			img.set_pixel(x, line_y, line_color)
			img.set_pixel(x, line_y + 1, line_color)

	file_icon_texture = ImageTexture.create_from_image(img)
	return file_icon_texture


func _create_exit_button() -> void:
	if has_node("ExitComputerButton"):
		return

	var exit_button := Button.new()
	exit_button.name = "ExitComputerButton"
	exit_button.text = "Exit Computer"
	exit_button.anchor_left = 1.0
	exit_button.anchor_right = 1.0
	exit_button.anchor_top = 1.0
	exit_button.anchor_bottom = 1.0
	exit_button.offset_left = -220.0
	exit_button.offset_right = -40.0
	exit_button.offset_top = -70.0
	exit_button.offset_bottom = -20.0
	exit_button.custom_minimum_size = Vector2(180, 44)
	exit_button.focus_mode = Control.FOCUS_ALL
	exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	exit_button.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	exit_button.top_level = true

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.16, 0.24, 0.32)
	normal_style.border_color = Color(0.3, 0.55, 0.8)
	normal_style.border_width_bottom = 2
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	exit_button.add_theme_stylebox_override("normal", normal_style)

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.22, 0.34, 0.44)
	exit_button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color(0.12, 0.18, 0.26)
	pressed_style.border_color = Color(0.45, 0.7, 0.95)
	exit_button.add_theme_stylebox_override("pressed", pressed_style)

	exit_button.add_theme_color_override("font_color", Color(0.9, 0.97, 1))

	exit_button.connect("pressed", Callable(self, "_on_exit_computer_pressed"))
	add_child(exit_button)


func _on_exit_computer_pressed() -> void:
	if mission_timer and not mission_timer.is_stopped():
		mission_timer.stop()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not ResourceLoader.exists(EXIT_SCENE_PATH):
		push_error("Exit scene not found: %s" % EXIT_SCENE_PATH)
		return
	get_tree().change_scene_to_file(EXIT_SCENE_PATH)


func _create_window_folder_icon(name: String, content: Variant) -> Control:
	var container_size := Vector2(64, 80)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = container_size
	vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(container_size.x, 48)
	vbox.add_child(center)

	var folder := TextureButton.new()
	folder.ignore_texture_size = true
	folder.custom_minimum_size = Vector2(40, 40)
	folder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	folder.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	folder.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var icon_texture: Texture2D = null
	if content is Dictionary:
		var folder_icon_path := "res://textures/folder_icon.png"
		if ResourceLoader.exists(folder_icon_path):
			icon_texture = load(folder_icon_path) as Texture2D
	else:
		icon_texture = _get_file_icon_texture()

	if icon_texture:
		folder.texture_normal = icon_texture
	else:
		folder.texture_normal = null

	folder.modulate = Color(0.9, 0.9, 0.9)
	folder.connect("mouse_entered", func(): folder.modulate = Color(1, 1, 1))
	folder.connect("mouse_exited", func(): folder.modulate = Color(0.9, 0.9, 0.9))
	center.add_child(folder)

	var label := Label.new()
	label.text = name
	label.custom_minimum_size = Vector2(container_size.x, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.7, 0.9, 1))
	label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(label)

	folder.connect("pressed", Callable(self, "_on_folder_opened").bind(name, content))

	return vbox


func _close_window(folder_name: String) -> void:
	if open_windows.has(folder_name):
		open_windows[folder_name].queue_free()
		open_windows.erase(folder_name)
		return
	# Handle message window specially
	if folder_name == "New Message" and mail_message_window and is_instance_valid(mail_message_window):
		mail_message_window.queue_free()
		mail_message_window = null
		mail_message_label = null
		return
	if folder_name == "Send File":
		_close_send_prompt()
		return
	# fallback: try to find a panel that has a header with this title and free it
	for child in get_children():
		if child is PanelContainer:
			for gc in child.get_children():
				if gc is ColorRect:
					for lbl in gc.get_children():
						if lbl is Label and lbl.text == folder_name:
							child.queue_free()
							return
