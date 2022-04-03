extends Node


var p_level = preload("res://Scenes/Level.tscn")

var level: Spatial = null
var camera: CustomCamera = null
var grid: Spatial = null
var collectors: Spatial = null

var mouse_hover_target = null
var mouse_selection_target = null
var mouse_cast_info: Dictionary = {}

# Currency
var fuel_amount = 0
var metal_amount = 0


func _ready():
	camera = $Level/CustomCamera
	pass
#	start_game()


func _physics_process(delta):
	mouse_cast_info = camera.mouse_3d_projection()
	_check_cursor_hover()
	_check_cursor_click()
	print("Fuel: ", fuel_amount, " | Metal: ", metal_amount)

#
#func _unhandled_input(event):
#	if level:
#		if event is InputEventMouseMotion:
#			mouse_cast_info = camera.mouse_3d_projection()
#			var collider = mouse_cast_info.get("collider")
#			if mouse_hover_target and not mouse_hover_target == collider:
#				if not mouse_hover_target == mouse_selection_target:
#					if mouse_hover_target.has_method("unhover"):
#						mouse_hover_target.unhover()
#				else:
#					mouse_hover_target.select()
#			mouse_hover_target = collider
#			if mouse_hover_target:
#				if not mouse_hover_target == mouse_selection_target:
#					if mouse_hover_target.has_method("hover"):
#						mouse_hover_target.hover()




func start_game():
	if level:
		level.queue_free()
	level = p_level.instance()
	add_child(level)
	camera = level.get_node("CustomCamera")
	camera.set_current(true)
	grid = level.get_node("Grid")
	collectors = level.get_node("Resources/Collectors")


func _check_cursor_hover():
	var collider = mouse_cast_info.get("collider")

	if not mouse_hover_target == collider:
		_unhover_current()
	mouse_hover_target = collider

	if not mouse_hover_target:
		return

	match mouse_hover_target.get_class():
		"ResourceCollector": _hover_check_resource_collector()


func _check_cursor_click():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	if not mouse_hover_target:
		return

	if mouse_left_clicked and not mouse_hover_target == mouse_selection_target:
		_unselect_current()

	match mouse_hover_target.get_class():
		"ResourceCollector": _click_check_resource_collector()


func _click_check_resource_collector():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	match mouse_hover_target.state:

		ResourceCollector.State.NONE: pass

		ResourceCollector.State.HOVERED:
			if mouse_left_clicked:
				if not mouse_hover_target.building:
					mouse_hover_target.state = ResourceCollector.State.CLICKED
					var amount = mouse_hover_target.production_amount
					match mouse_hover_target.resource_type:
						ResourceCollector.ResourceType.FUEL:
							add_fuel(amount)
						ResourceCollector.ResourceType.METAL:
							add_metal(amount)

		ResourceCollector.State.CLICKED:
			if mouse_left_released:
				if not mouse_hover_target.building:
					mouse_hover_target.state = ResourceCollector.State.HOVERED

		ResourceCollector.State.SELECTED: pass


func _hover_check_resource_collector():
	match mouse_hover_target.state:

		ResourceCollector.State.NONE:
			mouse_hover_target.state = ResourceCollector.State.HOVERED
			print("State: ", mouse_hover_target.state)

		ResourceCollector.State.HOVERED: pass

		ResourceCollector.State.CLICKED: pass

		ResourceCollector.State.SELECTED: pass


func _unselect_current():
	if not mouse_selection_target:
		return
	match mouse_hover_target.get_class():
		"ResourceCollector": mouse_hover_target.state = ResourceCollector.State.NONE
	mouse_selection_target = null


func _unhover_current():
	if not mouse_hover_target:
		return

	match mouse_hover_target.get_class():
		"ResourceCollector": mouse_hover_target.state = ResourceCollector.State.NONE
	mouse_hover_target = null


func add_fuel(amount: int):
	fuel_amount += amount


func add_metal(amount: int):
	metal_amount += amount
