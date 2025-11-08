# Desktop System Refactoring

The computer desktop system has been refactored into reusable components:

## File Structure

### 1. `base_desktop.gd` - Base Desktop Environment
**Purpose**: Provides the core desktop UI and functionality
**Features**:
- Desktop background with wallpaper support
- Top bar with app menu and time
- Taskbar
- Custom cursor
- Window creation and management system
- Exit button
- Draggable windows with close buttons

**Use this when**: You want to create any kind of computer interface/application

### 2. `folder_race_minigame.gd` - Folder Race Mini-Game
**Purpose**: The complete folder hunting mini-game
**Extends**: `base_desktop.gd`
**Features**:
- All features from base_desktop
- Mail system with contacts
- Notes window
- Folder tree generation and navigation
- Target file searching mechanic
- Mission timer with stress effects
- Audio feedback (ticking, stress drone, success sounds)
- Screen shake effects
- Fail sequence with scene transition

**Use this when**: You want the complete folder race game

### 3. `computer_desktop.gd` - Backward Compatibility
**Purpose**: Maintains compatibility with existing scenes
**Extends**: `folder_race_minigame.gd`
**Note**: This file just extends the mini-game for backward compatibility

## How to Use

### Creating a New Desktop Application

```gdscript
extends "res://scripts/base_desktop.gd"

func _ready() -> void:
    super._ready()  # Initialize base desktop
    
    # Add your custom windows and features
    var my_window := create_window("My App", Vector2(100, 100), Vector2(400, 300), true)
    var content := find_child_by_name(my_window, "content")
    
    # Add your content to the window
    # ...
    
    add_child(my_window)
```

### Using the Folder Race Mini-Game

```gdscript
# In your scene, attach this script:
extends "res://scripts/folder_race_minigame.gd"

# Or use computer_desktop.gd for existing scenes (same thing)
```

## Base Desktop API

### Window Management
- `create_window(title: String, pos: Vector2, size: Vector2, is_dark: bool = false) -> PanelContainer`
- `bring_to_front(win: Node) -> void`
- `find_child_by_name(root: Node, name: String) -> Node`

### Scene Navigation
- Override `_on_exit_computer_pressed()` to customize exit behavior

## Example

See `example_desktop_app.gd` for a simple example of extending the base desktop.

## Benefits of This Structure

1. **Separation of Concerns**: Core desktop UI is separate from game logic
2. **Reusability**: Create multiple desktop applications using the same base
3. **Maintainability**: Changes to UI don't affect game logic and vice versa
4. **Extensibility**: Easy to add new desktop applications
5. **Backward Compatibility**: Existing scenes continue to work

## Migration Guide

If you have an existing scene using `computer_desktop.gd`, it will continue to work without changes.

To create a new non-game desktop application:
1. Create a new script that extends `"res://scripts/base_desktop.gd"`
2. Override `_ready()` and call `super._ready()`
3. Add your custom windows and functionality
