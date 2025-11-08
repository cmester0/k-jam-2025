extends WorldEnvironment

@export_group("Ambient Light")
@export var ambient_light_color: Color = Color(0.18, 0.20, 0.24)
@export var ambient_light_energy: float = 0.3
@export var ambient_light_sky_contribution: float = 0.5

@export_group("Tonemap")
@export var tonemap_exposure: float = 1.1
@export var tonemap_white: float = 1.0

@export_group("Ambient Occlusion (SSAO)")
@export var ssao_enabled: bool = true
@export var ssao_radius: float = 1.2
@export var ssao_intensity: float = 3.0
@export var ssao_power: float = 1.8
@export var ssao_detail: float = 0.5
@export var ssao_horizon: float = 0.06
@export var ssao_sharpness: float = 0.98
@export var ssao_light_affect: float = 0.1
@export var ssao_ao_channel_affect: float = 0.6

@export_group("Indirect Lighting (SSIL)")
@export var ssil_enabled: bool = true
@export var ssil_radius: float = 5.0
@export var ssil_intensity: float = 1.5
@export var ssil_sharpness: float = 0.98
@export var ssil_normal_rejection: float = 1.0

@export_group("Screen Space Reflections (SSR)")
@export var ssr_enabled: bool = true
@export var ssr_max_steps: int = 128
@export var ssr_fade_in: float = 0.15
@export var ssr_fade_out: float = 2.5
@export var ssr_depth_tolerance: float = 0.2

@export_group("Global Illumination (SDFGI)")
@export var sdfgi_enabled: bool = false
@export var sdfgi_cascades: int = 4
@export var sdfgi_min_cell_size: float = 0.2
@export var sdfgi_bounce_feedback: float = 0.3
@export var sdfgi_read_sky_light: bool = false
@export var sdfgi_use_occlusion: bool = true

@export_group("Glow/Bloom")
@export var glow_enabled: bool = true
@export var glow_intensity: float = 0.4
@export var glow_strength: float = 1.0
@export var glow_bloom: float = 0.15
@export var glow_blend_mode: int = 2

@export_group("Adjustments")
@export var brightness: float = 1.0
@export var contrast: float = 1.1
@export var saturation: float = 1.15

func _ready() -> void:
	_setup_environment()
	_setup_viewport_settings()

func _setup_environment() -> void:
	var env := Environment.new()
	
	env.ambient_light_color = ambient_light_color
	env.ambient_light_energy = ambient_light_energy
	env.ambient_light_sky_contribution = ambient_light_sky_contribution
	
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = tonemap_exposure
	env.tonemap_white = tonemap_white
	
	env.ssao_enabled = ssao_enabled
	env.ssao_radius = ssao_radius
	env.ssao_intensity = ssao_intensity
	env.ssao_power = ssao_power
	env.ssao_detail = ssao_detail
	env.ssao_horizon = ssao_horizon
	env.ssao_sharpness = ssao_sharpness
	env.ssao_light_affect = ssao_light_affect
	env.ssao_ao_channel_affect = ssao_ao_channel_affect
	
	env.ssil_enabled = ssil_enabled
	env.ssil_radius = ssil_radius
	env.ssil_intensity = ssil_intensity
	env.ssil_sharpness = ssil_sharpness
	env.ssil_normal_rejection = ssil_normal_rejection
	
	env.ssr_enabled = ssr_enabled
	env.ssr_max_steps = ssr_max_steps
	env.ssr_fade_in = ssr_fade_in
	env.ssr_fade_out = ssr_fade_out
	env.ssr_depth_tolerance = ssr_depth_tolerance
	
	env.sdfgi_enabled = sdfgi_enabled
	env.sdfgi_cascades = sdfgi_cascades
	env.sdfgi_min_cell_size = sdfgi_min_cell_size
	env.sdfgi_bounce_feedback = sdfgi_bounce_feedback
	env.sdfgi_read_sky_light = sdfgi_read_sky_light
	env.sdfgi_use_occlusion = sdfgi_use_occlusion
	
	env.glow_enabled = glow_enabled
	env.glow_intensity = glow_intensity
	env.glow_strength = glow_strength
	env.glow_bloom = glow_bloom
	env.glow_blend_mode = glow_blend_mode
	
	env.adjustment_enabled = true
	env.adjustment_brightness = brightness
	env.adjustment_contrast = contrast
	env.adjustment_saturation = saturation
	
	environment = env

func _setup_viewport_settings() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.msaa_3d = Viewport.MSAA_8X
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		viewport.use_taa = true
		viewport.use_debanding = true
		viewport.mesh_lod_threshold = 2.0
