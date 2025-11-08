extends Node
# Desktop Configuration - Controls which desktop mode is active
# Change DESKTOP_MODE to switch between different desktop experiences

enum DesktopMode {
	BROWSABLE,          # Browse folders, read mail, take notes (no game)
	READ_MAIL_GAME,     # Mini-game: Read all emails from coworkers
	FOLDER_RACE_GAME,   # Mini-game: Find file before time runs out
	ORGANIZE_FILES_GAME,# Mini-game: Drag files into folders to clean desktop
	POPUP_HELL_GAME     # Mini-game: Close all the popup windows!
}

# ⚙️ CHANGE THIS TO SWITCH DESKTOP MODES ⚙️
var current_mode: DesktopMode = DesktopMode.POPUP_HELL_GAME


func get_desktop_script_path() -> String:
	match current_mode:
		DesktopMode.BROWSABLE:
			return "res://scripts/browsable_desktop.gd"
		DesktopMode.READ_MAIL_GAME:
			return "res://scripts/read_mail_minigame.gd"
		DesktopMode.FOLDER_RACE_GAME:
			return "res://scripts/folder_race_minigame.gd"
		DesktopMode.ORGANIZE_FILES_GAME:
			return "res://scripts/organize_files_minigame.gd"
		DesktopMode.POPUP_HELL_GAME:
			return "res://scripts/pop_up_hell_minigame.gd"
		_:
			return "res://scripts/browsable_desktop.gd"


func get_mode_name() -> String:
	match current_mode:
		DesktopMode.BROWSABLE:
			return "Browsable Desktop"
		DesktopMode.READ_MAIL_GAME:
			return "Read Mail Mini-Game"
		DesktopMode.FOLDER_RACE_GAME:
			return "Folder Race Mini-Game"
		DesktopMode.ORGANIZE_FILES_GAME:
			return "Organize Files Mini-Game"
		DesktopMode.POPUP_HELL_GAME:
			return "Popup Hell Mini-Game"
		_:
			return "Unknown"
