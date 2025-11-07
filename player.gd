extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _process(delta):

	var look_speed = 1.5  # adjust sensitivity

	# Horizontal rotation (yaw)
	if Input.is_action_pressed("look_right"):
		rotation.y -= look_speed * delta
	if Input.is_action_pressed("look_left"):
		rotation.y += look_speed * delta

	# Vertical rotation (pitch)
	if Input.is_action_pressed("look_down"):
		rotation.x -= look_speed * delta
	if Input.is_action_pressed("look_up"):
		rotation.x += look_speed * delta

	# Clamp pitch so camera doesn't flip
	rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func _physics_process(delta: float) -> void:
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		# $Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
