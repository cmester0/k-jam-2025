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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_inside && get_parent().solved_task():
		get_parent().is_task_solved = false
		get_tree().root.get_node("./MapLoader").load_day(get_parent().day+1)
		get_parent().queue_free()
		get_tree().root.get_node("./MapLoader").unload_day(get_parent().day)
	pass
