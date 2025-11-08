extends Node3D
# Elevator that moves between floors

@export var elevator_width: float = 2.0
@export var elevator_depth: float = 2.0
@export var elevator_height: float = 2.5
@export var shaft_height: float = 20.0
@export var move_speed: float = 2.0
@export var door_open_speed: float = 1.5

var _is_moving: bool = false
var _doors_open: bool = false
var _current_floor: int = 0
var _target_floor: int = 0
var _floors: Array[float] = [0.0, 10.0, 20.0]

var _elevator_car: Node3D
var _left_door: StaticBody3D
var _right_door: StaticBody3D
var _door_open_amount: float = 0.0

func setup(width: float, depth: float, height: float) -> void:
	elevator_width = width
	elevator_depth = depth
	elevator_height = height
	_rebuild()

func _ready() -> void:
	_rebuild()
	# Start with doors open
	_doors_open = true
	_door_open_amount = 1.0
	call_deferred("_update_door_positions")

func _rebuild() -> void:
	_clear_children()
	_build_elevator_shaft()
	_build_elevator_car()

func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _build_elevator_shaft() -> void:
	var shaft_mat := StandardMaterial3D.new()
	shaft_mat.albedo_color = Color(0.15, 0.15, 0.15)
	shaft_mat.roughness = 0.9
	
	# Back wall (visual only, no collision)
	var back_wall := _create_mesh_wall(
		Vector3(elevator_width, elevator_height, 0.1),
		shaft_mat,
		Vector3(0, elevator_height * 0.5, -elevator_depth * 0.5 - 0.05)
	)
	back_wall.name = "BackWall"
	add_child(back_wall)

func _build_elevator_car() -> void:
	_elevator_car = Node3D.new()
	_elevator_car.name = "ElevatorCar"
	_elevator_car.position = Vector3(0, 0, 0)
	add_child(_elevator_car)
	
	var car_mat := StandardMaterial3D.new()
	car_mat.albedo_color = Color(0.7, 0.7, 0.75)
	car_mat.metallic = 0.3
	car_mat.roughness = 0.4
	var wall_thickness := 0.05

	# Elevator floor
	var floor := MeshInstance3D.new()
	floor.name = "Floor"
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(elevator_width, 0.1, elevator_depth)
	floor.mesh = floor_mesh
	floor.material_override = car_mat
	floor.position = Vector3(0, -0.05, 0)
	_elevator_car.add_child(floor)
	
	# Elevator ceiling
	var ceiling := MeshInstance3D.new()
	ceiling.name = "Ceiling"
	var ceiling_mesh := BoxMesh.new()
	ceiling_mesh.size = Vector3(elevator_width, 0.1, elevator_depth)
	ceiling.mesh = ceiling_mesh
	ceiling.material_override = car_mat
	ceiling.position = Vector3(0, elevator_height, 0)
	_elevator_car.add_child(ceiling)
	
	# Side walls of elevator car (visual layer, collision handled below)
	var side_mat := StandardMaterial3D.new()
	side_mat.albedo_color = Color(0.6, 0.6, 0.65)
	side_mat.metallic = 0.3
	side_mat.roughness = 0.4
	var wall_height := elevator_height - 0.05
	var wall_center_y := wall_height * 0.5
	var door_clearance_limit := maxf(0.2, elevator_depth - 0.2)
	var door_clearance := clampf(0.6, 0.2, door_clearance_limit)
	var collision_center_z := (elevator_depth - door_clearance) * -0.5
	var collision_depth := elevator_depth - door_clearance
	
	# Left side wall
	var left_side := MeshInstance3D.new()
	left_side.name = "LeftSide"
	var left_mesh := BoxMesh.new()
	left_mesh.size = Vector3(wall_thickness, wall_height, elevator_depth)
	left_side.mesh = left_mesh
	left_side.material_override = side_mat
	left_side.position = Vector3(-elevator_width * 0.5 + wall_thickness * 0.5, wall_center_y, 0)
	_elevator_car.add_child(left_side)
	
	# Right side wall
	var right_side := MeshInstance3D.new()
	right_side.name = "RightSide"
	var right_mesh := BoxMesh.new()
	right_mesh.size = Vector3(wall_thickness, wall_height, elevator_depth)
	right_side.mesh = right_mesh
	right_side.material_override = side_mat
	right_side.position = Vector3(elevator_width * 0.5 - wall_thickness * 0.5, wall_center_y, 0)
	_elevator_car.add_child(right_side)
	
	# Back wall of car
	var back_side := MeshInstance3D.new()
	back_side.name = "BackSide"
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(elevator_width, wall_height, wall_thickness)
	back_side.mesh = back_mesh
	back_side.material_override = side_mat
	back_side.position = Vector3(0, wall_center_y, -elevator_depth * 0.5 + wall_thickness * 0.5)
	_elevator_car.add_child(back_side)

	# Collision shapes for cab interior
	var cab_collision := StaticBody3D.new()
	cab_collision.name = "CabCollision"
	_elevator_car.add_child(cab_collision)

	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(elevator_width - wall_thickness, 0.1, elevator_depth - wall_thickness)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector3(0, -0.05, 0)
	cab_collision.add_child(floor_collision)

	var left_collision := CollisionShape3D.new()
	var left_shape := BoxShape3D.new()
	left_shape.size = Vector3(wall_thickness, wall_height, collision_depth)
	left_collision.shape = left_shape
	left_collision.position = Vector3(-elevator_width * 0.5 + wall_thickness * 0.5, wall_height * 0.5, collision_center_z)
	cab_collision.add_child(left_collision)

	var right_collision := CollisionShape3D.new()
	var right_shape := BoxShape3D.new()
	right_shape.size = Vector3(wall_thickness, wall_height, collision_depth)
	right_collision.shape = right_shape
	right_collision.position = Vector3(elevator_width * 0.5 - wall_thickness * 0.5, wall_height * 0.5, collision_center_z)
	cab_collision.add_child(right_collision)

	var back_collision := CollisionShape3D.new()
	var back_shape := BoxShape3D.new()
	back_shape.size = Vector3(elevator_width - wall_thickness, wall_height, wall_thickness)
	back_collision.shape = back_shape
	back_collision.position = Vector3(0, wall_height * 0.5, -elevator_depth * 0.5 + wall_thickness * 0.5)
	cab_collision.add_child(back_collision)
	
	# Ceiling light
	var light := OmniLight3D.new()
	light.name = "CeilingLight"
	light.light_color = Color(1.0, 0.95, 0.9)
	light.light_energy = 1.5
	light.omni_range = 8.0
	light.position = Vector3(0, elevator_height - 0.2, 0)
	_elevator_car.add_child(light)
	
	# Door frame
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.5, 0.5, 0.55)
	door_mat.metallic = 0.5
	door_mat.roughness = 0.3
	
	var door_size := Vector3(elevator_width * 0.5, elevator_height - 0.2, 0.1)
	
	# Left door
	_left_door = StaticBody3D.new()
	_left_door.name = "LeftDoor"
	_left_door.position = Vector3(-elevator_width * 0.25, elevator_height * 0.5, elevator_depth * 0.5)
	_elevator_car.add_child(_left_door)

	var left_door_mesh := MeshInstance3D.new()
	var door_mesh := BoxMesh.new()
	door_mesh.size = door_size
	left_door_mesh.mesh = door_mesh
	left_door_mesh.material_override = door_mat
	_left_door.add_child(left_door_mesh)

	var left_door_collision := CollisionShape3D.new()
	var door_shape := BoxShape3D.new()
	door_shape.size = door_size
	left_door_collision.shape = door_shape
	_left_door.add_child(left_door_collision)
	
	# Right door
	_right_door = StaticBody3D.new()
	_right_door.name = "RightDoor"
	_right_door.position = Vector3(elevator_width * 0.25, elevator_height * 0.5, elevator_depth * 0.5)
	_elevator_car.add_child(_right_door)

	var right_door_mesh := MeshInstance3D.new()
	right_door_mesh.mesh = door_mesh
	right_door_mesh.material_override = door_mat
	_right_door.add_child(right_door_mesh)

	var right_door_collision := CollisionShape3D.new()
	right_door_collision.shape = door_shape
	_right_door.add_child(right_door_collision)
	
	# Call button panel
	var panel := MeshInstance3D.new()
	panel.name = "ButtonPanel"
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(0.5, 0.8, 0.05)
	panel.mesh = panel_mesh
	var panel_mat := StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.2, 0.2, 0.25)
	panel_mat.roughness = 0.5
	panel.material_override = panel_mat
	panel.position = Vector3(elevator_width * 0.5 - 0.3, 1.2, 0)
	_elevator_car.add_child(panel)
	
	# Add button lights
	for i in range(3):
		var button_light := MeshInstance3D.new()
		button_light.name = "Button%d" % (i + 1)
		var button_mesh := CylinderMesh.new()
		button_mesh.top_radius = 0.05
		button_mesh.bottom_radius = 0.05
		button_mesh.height = 0.02
		button_light.mesh = button_mesh
		var button_mat := StandardMaterial3D.new()
		button_mat.albedo_color = Color(0.1, 0.8, 0.1) if i == _current_floor else Color(0.3, 0.3, 0.3)
		button_mat.emission_enabled = i == _current_floor
		button_mat.emission = Color(0.1, 1.0, 0.1)
		button_mat.emission_energy_multiplier = 2.0 if i == _current_floor else 0.0
		button_light.material_override = button_mat
		button_light.position = Vector3(0, 0.25 - i * 0.15, 0.03)
		button_light.rotation_degrees = Vector3(90, 0, 0)
		panel.add_child(button_light)

func _process(delta: float) -> void:
	if _is_moving:
		var target_y: float = float(_floors[_target_floor])
		var current_y: float = _elevator_car.position.y
		var direction: float = float(sign(target_y - current_y))
		var move_amount: float = direction * move_speed * delta
		
		if abs(target_y - current_y) <= abs(move_amount):
			_elevator_car.position.y = target_y
			_is_moving = false
			_current_floor = _target_floor
			_update_floor_indicator()
			call_deferred("open_doors")
		else:
			_elevator_car.position.y += move_amount
	
	# Animate doors
	if _doors_open and _door_open_amount < 1.0:
		_door_open_amount = min(1.0, _door_open_amount + delta * door_open_speed)
		_update_door_positions()
	elif not _doors_open and _door_open_amount > 0.0:
		_door_open_amount = max(0.0, _door_open_amount - delta * door_open_speed)
		_update_door_positions()

func _update_door_positions() -> void:
	if _left_door and _right_door:
		var offset := _door_open_amount * elevator_width * 0.35
		_left_door.position.x = -elevator_width * 0.25 - offset
		_right_door.position.x = elevator_width * 0.25 + offset

func _update_floor_indicator() -> void:
	var indicator := get_node_or_null("FloorIndicator")
	if indicator and indicator is Label3D:
		indicator.text = "FLOOR %d" % (_current_floor + 1)

func open_doors() -> void:
	_doors_open = true

func close_doors() -> void:
	_doors_open = false

func move_to_floor(floor: int) -> void:
	if floor < 0 or floor >= _floors.size():
		return
	if _is_moving:
		return
	
	_target_floor = floor
	if _target_floor != _current_floor:
		close_doors()
		await get_tree().create_timer(1.0).timeout
		_is_moving = true

func _create_mesh_wall(size: Vector3, material: StandardMaterial3D, pos: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	return mesh_instance
