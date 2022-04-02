extends Spatial


export(int) var scroll_speed = 5
export(int) var deacceleration_speed = 3
export(int) var border_width = 50
export(Vector2) var h_confine = Vector2(0, 0)
export(float) var zoom_speed = 0.2
export(float) var zoom_deacceleration = 0.3
export(float) var zoom_max = 10.0
export(float) var zoom_min = 0.0

var _current_zoom = 0.0
var _target_zoom = 0.0
var _target_pos = Vector2()

onready var o_camera = get_node("Camera")


func _ready():
	_target_pos = o_camera.translation


func _physics_process(delta):
	_pan_movement(delta)
	_zoom_movement(delta)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			_target_zoom += zoom_speed
		elif event.button_index == BUTTON_WHEEL_UP:
			_target_zoom -= zoom_speed


func _pan_movement(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var direction = 0.0

	# Check for border mouse interaction (pan)
	if mouse_pos.x <= border_width:
		direction -= border_width - mouse_pos.x
	elif mouse_pos.x >= screen_size.x - border_width:
		direction += mouse_pos.x - (screen_size.x - border_width)

	# Normalize value
	direction = direction / border_width

	# Deacceleration
	if direction != 0:
		_target_pos.x += direction * scroll_speed * delta
	else:
		_target_pos.x += (global_transform.origin.x - _target_pos.x) * deacceleration_speed * delta

	# Apply movement
	global_transform.origin.x = lerp(
		global_transform.origin.x, _target_pos.x, delta
	)


func _zoom_movement(delta):
	var mouse_wheel_up = Input.is_action_just_released("mouse_wheel_up")
	var mouse_wheel_down = Input.is_action_just_released("mouse_wheel_down")

	# Check for mouse scroll
	if mouse_wheel_up:
		_target_zoom += zoom_speed * delta
	elif mouse_wheel_down:
		_target_zoom -= zoom_speed * delta
	else:
		_target_zoom += (o_camera.translation.z - _target_zoom) * zoom_deacceleration * delta

	_target_zoom = clamp(_target_zoom, zoom_min, zoom_max)

	_current_zoom = lerp(o_camera.translation.z, _target_zoom, delta)
	_apply_zoom(_current_zoom)


func _apply_zoom(zoom_factor):
	# Y Ratio -> 0.5
	translation.y = zoom_factor * 0.5

	# FOV Ratio -> 18.0
	o_camera.fov = clamp(zoom_factor * 12.0, 70, 120)

	o_camera.translation.z = zoom_factor
