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
	$GUI/Panel2/LabelHovered.text = str(mouse_hover_target)
	$GUI/Panel2/LabelSelected.text = str(mouse_selection_target)



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
	match mouse_selection_target.get_class():
		"ResourceCollector": mouse_selection_target.state = Global.SelectorState.NONE
		"Cell": mouse_selection_target.state = Global.SelectorState.NONE
	mouse_selection_target = null


func _unhover_current():
	if not mouse_hover_target:
		return
	match mouse_hover_target.get_class():
		"ResourceCollector": _unhover_resource_collector()
		"Cell": _unhover_cell()
	mouse_hover_target = null

# ----- Checking stuff -----

func _check_cursor_hover():
	var collider = mouse_cast_info.get("collider")

	if not collider:
		_unhover_current()
	else:
		if not mouse_hover_target == collider:
			_unhover_current()
			mouse_hover_target = collider
			match mouse_hover_target.get_class():
				"ResourceCollector": _hovered_resource_collector()
				"Cell": _hovered_cell()


func _check_cursor_click():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	if (
		not mouse_left_clicked
		and not mouse_left_pressed
		and not mouse_left_released
	):
		return
	if not mouse_hover_target:
		_unselect_current()
	else:
		if mouse_left_clicked:
			match mouse_hover_target.get_class():
				"ResourceCollector": _clicked_resource_collector()
				"Cell": _clicked_cell()
		elif mouse_left_pressed:
			match mouse_hover_target.get_class():
				"ResourceCollector": _pressed_resource_collector()
				"Cell": _pressed_cell()
		elif mouse_left_released:
			match mouse_hover_target.get_class():
				"ResourceCollector": _released_resource_collector()
				"Cell": _released_cell()


# ----- Resource Collector Stuff -----

func _hovered_resource_collector():
	match mouse_hover_target.state:

		Global.SelectorState.NONE:
			mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED:
			mouse_hover_target.state = Global.SelectorState.HOVERED


func _clicked_resource_collector():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED:
			_unselect_current()
			mouse_selection_target = mouse_hover_target
			if not mouse_hover_target.building:
				mouse_hover_target.state = Global.SelectorState.CLICKED
				var amount = mouse_hover_target.production_amount
				match mouse_hover_target.resource_type:
					Global.ResourceType.FUEL:
						fuel_amount += amount
					Global.ResourceType.METAL:
						metal_amount += amount
			else:
				mouse_hover_target.state = Global.SelectorState.SELECTED
				print("Building found")

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED:
			_unselect_current()
			mouse_selection_target = mouse_hover_target
			if not mouse_hover_target.building:
				mouse_hover_target.state = Global.SelectorState.CLICKED
				var amount = mouse_hover_target.production_amount
				match mouse_hover_target.resource_type:
					Global.ResourceType.FUEL:
						fuel_amount += amount
					Global.ResourceType.METAL:
						metal_amount += amount


func _pressed_resource_collector():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _released_resource_collector():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED:
			if not mouse_hover_target.building:
				mouse_hover_target.state = Global.SelectorState.SELECTED

		Global.SelectorState.SELECTED: pass


func _unhover_resource_collector():
	if mouse_selection_target == mouse_hover_target:
		mouse_hover_target.state = Global.SelectorState.SELECTED
	else:
		mouse_hover_target.state = Global.SelectorState.NONE

# ----- Cell Stuff -----

func _hovered_cell():
	match mouse_hover_target.state:

		Global.SelectorState.NONE:
			if not mouse_hover_target.building:
				mouse_hover_target.state = Global.SelectorState.HOVERED
			else:
				mouse_hover_target.state = Global.SelectorState.NONE

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _clicked_cell():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED:
			if not mouse_hover_target.building:
				_unselect_current()
				mouse_selection_target = mouse_hover_target
			else:
				mouse_hover_target.state = Global.SelectorState.NONE

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED:
			if mouse_hover_target.building:
				mouse_hover_target.state = Global.SelectorState.NONE


func _pressed_cell():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _released_cell():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _unhover_cell():
	if mouse_selection_target == mouse_hover_target:
		mouse_hover_target.state = Global.SelectorState.SELECTED
	else:
		mouse_hover_target.state = Global.SelectorState.NONE
