extends Node
# Desktop Configuration - Controls which desktop mode is active
# Change DESKTOP_MODE to switch between different desktop experiences

enum DesktopMode {
	BROWSABLE,        # Browse folders, read mail, take notes (no game)
	READ_MAIL_GAME,   # Mini-game: Read all emails from coworkers
	FOLDER_RACE_GAME  # Mini-game: Find file before time runs out
}

# ⚙️ CHANGE THIS TO SWITCH DESKTOP MODES ⚙️
var current_mode: DesktopMode = DesktopMode.READ_MAIL_GAME


func get_desktop_script_path() -> String:
	match current_mode:
		DesktopMode.BROWSABLE:
			return "res://scripts/browsable_desktop.gd"
		DesktopMode.READ_MAIL_GAME:
			return "res://scripts/read_mail_minigame.gd"
		DesktopMode.FOLDER_RACE_GAME:
			return "res://scripts/folder_race_minigame.gd"
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
		_:
			return "Unknown"
