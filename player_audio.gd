extends AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = preload("res://sound/get_back_to_work.wav")
	volume_db = -15
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# if playing:
	# 	return
	# play()
	#wait_time += delta
	#if wait_time > 5:
		#play()
		#wait_time = 0
