extends Node


var p_level = preload("res://Scenes/Level/Level.tscn")

var level: Spatial = null
var camera: CustomCamera = null
var grid: Spatial = null
var collectors: Grid = null

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


func start_game():
	if level:
		level.queue_free()
	level = p_level.instance()
	add_child(level)
	camera = level.get_node("CustomCamera")
	camera.set_current(true)
	grid = level.get_node("Grid")
	collectors = level.get_node("Resources/Collectors")


func add_fuel(amount: int):
	fuel_amount += amount


func add_metal(amount: int):
	metal_amount += amount


func _unselect_current():
	if not mouse_selection_target:
		return
	match mouse_hover_target.get_class():
		"ResourceCollector": mouse_hover_target.state = Global.SelectorState.NONE
		"Cell": mouse_hover_target.state = Global.SelectorState.NONE
	mouse_selection_target = null


func _unhover_current():
	if not mouse_hover_target:
		return

	match mouse_hover_target.get_class():
		"ResourceCollector": mouse_hover_target.state = Global.SelectorState.NONE
		"Cell": mouse_hover_target.state = Global.SelectorState.NONE
	mouse_hover_target = null

# ----- Checking stuff -----

func _check_cursor_hover():
	var collider = mouse_cast_info.get("collider")

	if not mouse_hover_target == collider:
		_unhover_current()
	mouse_hover_target = collider

	if not mouse_hover_target:
		return

	match mouse_hover_target.get_class():
		"ResourceCollector": _hover_check_resource_collector()
		"Cell": _hover_check_cell()


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
		"Cell": _click_check_cell()

# ----- Resource Collector Stuff -----

func _hover_check_resource_collector():
	match mouse_hover_target.state:

		Global.SelectorState.NONE:
			mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _click_check_resource_collector():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED:
			if mouse_left_clicked:
				if not mouse_hover_target.building:
					mouse_hover_target.state = Global.SelectorState.CLICKED
					var amount = mouse_hover_target.production_amount
					match mouse_hover_target.resource_type:
						Global.ResourceType.FUEL:
							add_fuel(amount)
						Global.ResourceType.METAL:
							add_metal(amount)

		Global.SelectorState.CLICKED:
			if mouse_left_released:
				if not mouse_hover_target.building:
					mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.SELECTED: pass

# ----- Cell Stuff -----

func _hover_check_cell():
	match mouse_hover_target.state:

		Global.SelectorState.NONE:
			mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _click_check_cell():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED:
			if mouse_left_clicked:
				if not mouse_hover_target.building:
					mouse_hover_target.state = Global.SelectorState.CLICKED
					var amount = mouse_hover_target.production_amount
					match mouse_hover_target.resource_type:
						Global.ResourceType.FUEL:
							add_fuel(amount)
						Global.ResourceType.METAL:
							add_metal(amount)

		Global.SelectorState.CLICKED:
			if mouse_left_released:
				if not mouse_hover_target.building:
					mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.SELECTED: pass
