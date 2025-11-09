extends Node

const SPAWN_ELEVATOR := "elevator"
const SPAWN_DESK := "desk"

var current_day: int = 1
var desk_task_ready: bool = false
var next_spawn_location: String = SPAWN_ELEVATOR
var desk_spawn_position: Vector3 = Vector3.ZERO
var desk_spawn_ready: bool = false
var desk_spawn_basis: Basis = Basis.IDENTITY
var desk_focus_position: Vector3 = Vector3.ZERO
var desk_focus_basis: Basis = Basis.IDENTITY
var desk_focus_ready: bool = false
var desk_focus_duration: float = 1.0

signal desk_task_flagged
signal day_progressed(new_day: int)

func mark_desk_ready() -> void:
	if desk_task_ready:
		return
	desk_task_ready = true
	emit_signal("desk_task_flagged")
	print("GameState: Desk task ready for day %d." % current_day)

func can_start_new_day() -> bool:
	return desk_task_ready

func start_new_day() -> bool:
	if not desk_task_ready:
		return false
	desk_task_ready = false
	current_day += 1
	emit_signal("day_progressed", current_day)
	print("GameState: Advancing to day %d." % current_day)
	return true

func reset_progress() -> void:
	desk_task_ready = false
	current_day = 1
	next_spawn_location = SPAWN_ELEVATOR
	clear_desk_spawn()

func set_desk_spawn(position: Vector3, target: Vector3) -> void:
	var forward := (target - position)
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	var z_axis := -forward
	var x_axis := Vector3.UP.cross(z_axis)
	if x_axis.length_squared() <= 0.0001:
		x_axis = Vector3.RIGHT
	else:
		x_axis = x_axis.normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	var basis := Basis(x_axis, y_axis, z_axis)
	set_desk_spawn_transform(Transform3D(basis, position))

func set_desk_spawn_transform(transform: Transform3D) -> void:
	desk_spawn_position = transform.origin
	desk_spawn_basis = transform.basis.orthonormalized()
	desk_spawn_ready = true

func clear_desk_spawn() -> void:
	desk_spawn_ready = false
	desk_spawn_position = Vector3.ZERO
	desk_spawn_basis = Basis.IDENTITY
	clear_desk_focus()

func set_next_spawn(location: String) -> void:
	next_spawn_location = location

func should_spawn_at_desk() -> bool:
	return next_spawn_location == SPAWN_DESK and desk_spawn_ready

func set_desk_focus_transform(transform: Transform3D, duration: float) -> void:
	desk_focus_basis = transform.basis.orthonormalized()
	desk_focus_position = transform.origin
	desk_focus_ready = true
	desk_focus_duration = maxf(0.01, duration)

func has_desk_focus() -> bool:
	return desk_focus_ready

func clear_desk_focus() -> void:
	desk_focus_ready = false
	desk_focus_position = Vector3.ZERO
	desk_focus_basis = Basis.IDENTITY
	desk_focus_duration = 1.0
