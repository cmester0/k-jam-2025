extends Area3D

@export var target_scene : String = "res://scenes/Bootscreen.tscn"
var player_inside := false
@export var camera_node_path : NodePath = "../Player/Camera3D"  # Path from this node to the camera
@export var camera_target_position : Vector3 = Vector3(0, 0, 0)  # World position
@export var camera_target_rotation : Vector3 = Vector3(0, 0, 0)  # World position
@export var camera_move_duration : float = 1.0

@onready var camera : Camera3D = get_node(camera_node_path)

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false

func _process(delta):
	var orb = get_tree().root.get_node_or_null("./MapLoader/Main/Orb")
	if orb:
		orb.position = camera_target_position
		
	if player_inside:
		if get_parent():
			get_parent().is_task_solved = true

	if player_inside and Input.is_action_just_pressed("ui_accept"):
		var tween = get_tree().create_tween()
		var direction = (camera_target_position - camera.global_transform.origin).normalized()
		
		# Apply rotation
		camera.frozen = true
		
		# Assume `camera` is a Camera3D node and `target_position` is a Vector3
		var target_transform = camera.global_transform.looking_at(camera_target_position, Vector3.UP)
		
		# Tween the camera's rotation (basis) over 1 second
		tween.tween_property(
			camera, "global_transform:basis",
			target_transform.basis, camera_move_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		tween.tween_property(
			camera,
			"global_transform:origin",
			camera_target_position,
			camera_move_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel()
		tween.tween_property(
			camera,
			"rotation_degrees",
			camera_target_rotation,
			camera_move_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		tween.tween_callback(_on_tween_finished)

func _on_tween_finished():
	print("✅ switching sceens.")
	get_tree().change_scene_to_file(target_scene)
