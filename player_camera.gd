extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
