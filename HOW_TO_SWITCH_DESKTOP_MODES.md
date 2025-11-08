# 🖥️ How to Switch Desktop Modes

## Quick Start

Open `scripts/desktop_config.gd` and change this line:

```gdscript
# ⚙️ CHANGE THIS TO SWITCH DESKTOP MODES ⚙️
var current_mode: DesktopMode = DesktopMode.READ_MAIL_GAME
```

## Available Modes

### 1. `DesktopMode.BROWSABLE`
**Casual browsing mode - No game mechanics**
- Browse folders and files
- Read mail from contacts (simple messages)
- Take notes
- No objectives, no timer, just explore

**Use when:** You want a relaxed desktop environment

---

### 2. `DesktopMode.READ_MAIL_GAME`
**Mini-Game: Read all emails**
- Each contact has 3-4 emails
- Click contacts to see their inbox
- Read each email to mark it as read
- Complete when all emails are read
- Progress tracking with notifications

**Use when:** You want a simple task-based mini-game

---

### 3. `DesktopMode.FOLDER_RACE_GAME`
**Mini-Game: Find the file before time runs out**
- Urgent email from Alex requesting a specific file
- 60-second countdown timer
- Navigate folder maze to find the target file
- Stress effects (screen shake, audio, visual overlay)
- Success/failure outcomes

**Use when:** You want a high-pressure challenge

---

## How It Works

1. **Config file** (`desktop_config.gd`) stores which mode is active
2. **Dynamic loader** (`dynamic_desktop_loader.gd`) reads the config
3. **Scene loads** the appropriate desktop script automatically
4. **No scene changes needed** - just change the config variable!

## Example

```gdscript
# In desktop_config.gd

# For browsing mode:
var current_mode: DesktopMode = DesktopMode.BROWSABLE

# For read mail game:
var current_mode: DesktopMode = DesktopMode.READ_MAIL_GAME

# For folder race game:
var current_mode: DesktopMode = DesktopMode.FOLDER_RACE_GAME
```

Save the file and run the game - that's it! 🎮
