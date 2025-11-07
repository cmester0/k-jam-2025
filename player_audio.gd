extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# stream = preload("res://sound/untitled.wav")
	volume_db = -15
	#play()

var wait_time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#wait_time += delta
	#if wait_time > 5:
		#play()
		#wait_time = 0
