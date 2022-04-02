class_name CustomCamera
extends Camera


enum ZoomState {
	NORMAL,
	GRID_VIEW,
	SKY_VIEW,
}

const zoom_states = {
	ZoomState.NORMAL: {
		"translation": Vector3(0, 7, 13),
		"rotation": Vector3(-7.4, 0, 0),
		"fov": 42,
	},
	ZoomState.GRID_VIEW: {
		"translation": Vector3(0, 17, -5),
		"rotation": Vector3(-90, 0, 0),
		"fov": 48,
	},
	ZoomState.SKY_VIEW: {
		"translation": Vector3(0, 4.5, 7),
		"rotation": Vector3(48, 0, 0),
		"fov": 73,
	}
}

var mouse_3d: Vector3 = Vector3()
var transition_speed: int = 10

var _initial_translation = Vector3()


func _ready():
	_initial_translation = translation


func _physics_process(delta):
	cast_mouse_to_3d()


func get_class() -> String:
	return "CustomCamera"


func cast_mouse_to_3d() -> Dictionary:
	var mouse_pos = self.get_viewport().get_mouse_position()
	var space_state = get_world().direct_space_state
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * 1000

	var result = space_state.intersect_ray(from, to)

	return result


func set_state(state: int):
	var target_translation: Vector3 = zoom_states[state].translation
	var target_rotation: Vector3 = zoom_states[state].rotation
	var target_fov: int = zoom_states[state].fov

	# Tween translation
	$Tween.interpolate_property(
		self,
		"translation",
		translation,
		target_translation,
		target_translation.distance_to(translation) / transition_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
	)

	# Tween rotation
	$Tween.interpolate_property(
		self,
		"rotation_degrees",
		rotation_degrees,
		target_rotation,
		target_translation.distance_to(translation) / transition_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
	)

	# Tween fov
	$Tween.interpolate_property(
		self,
		"fov",
		fov,
		target_fov,
		target_translation.distance_to(translation) / transition_speed,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT_IN
	)

	$Tween.stop_all()
	$Tween.start()
