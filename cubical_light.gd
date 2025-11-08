extends Node
# Generic light flicker script that can be attached to any Light3D node.
# Works with OmniLight3D, SpotLight3D, DirectionalLight3D, etc.

@export var flicker_interval: float = 0.03
@export var flicker_weight: float = 0.05
@export var base_color: Color = Color(1.0, 1.0, 1.0)
@export var base_energy: float = 1.0

var flicker_time: float = 0.0
var light_node: Light3D = null
var blackout_time: float = 0.0
var is_blacked_out: bool = false
var next_blackout_in: float = 0.0
var blackout_duration: float = 0.0
var is_flickering: bool = false
var flicker_burst_time: float = 0.0
var flicker_burst_duration: float = 0.0
var next_flicker_burst_in: float = 0.0

func _ready() -> void:
	var parent = get_parent()
	if parent is Light3D:
		light_node = parent
		base_color = light_node.light_color
		base_energy = light_node.light_energy
		_schedule_next_blackout()
		_schedule_next_flicker_burst()
	else:
		push_error("cubical_light.gd must be a child of a Light3D node")

func _schedule_next_blackout() -> void:
	next_blackout_in = randf_range(10.0, 30.0)
	blackout_duration = randf_range(0.05, 0.4)

func _schedule_next_flicker_burst() -> void:
	next_flicker_burst_in = randf_range(3.0, 10.0)
	flicker_burst_duration = randf_range(0.5, 3.0)

func _process(delta: float) -> void:
	if not light_node:
		return
	
	next_blackout_in -= delta
	next_flicker_burst_in -= delta
	
	# Handle blackouts (complete light failure)
	if is_blacked_out:
		blackout_time += delta
		if blackout_time >= blackout_duration:
			is_blacked_out = false
			blackout_time = 0.0
			_schedule_next_blackout()
		else:
			light_node.light_energy = 0.0
			return
	elif next_blackout_in <= 0.0:
		is_blacked_out = true
		blackout_time = 0.0
		return
	
	# Handle flicker bursts (intermittent flickering)
	if is_flickering:
		flicker_burst_time += delta
		if flicker_burst_time >= flicker_burst_duration:
			is_flickering = false
			flicker_burst_time = 0.0
			_schedule_next_flicker_burst()
			# Reset to steady light
			light_node.light_color = base_color
			light_node.light_energy = base_energy
		else:
			# Active flickering
			flicker_time += delta
			if flicker_time > flicker_interval:
				var g = (1.0 - flicker_weight) + flicker_weight * randf()
				light_node.light_color = Color(g, g, g)
				light_node.light_energy = base_energy * g
				flicker_time = 0.0
	elif next_flicker_burst_in <= 0.0:
		is_flickering = true
		flicker_burst_time = 0.0
	else:
		# Steady light (no flickering)
		light_node.light_color = base_color
		light_node.light_energy = base_energy
