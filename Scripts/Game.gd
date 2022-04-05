extends Node


enum GameMode {
	SELECTION,
	PLACING,
	CUTSCENE,
}

const DELAY_BEFORE_DAMAGE = 1.0

var p_main_menu = preload("res://Scenes/Interface/MainMenu.tscn")
var p_lore_1 = preload("res://Scenes/Interface/Lore1Screen.tscn")
var p_level = preload("res://Scenes/Level/Level.tscn")

var level: Spatial = null
var camera: CustomCamera = null
var grid: CellGrid = null
var hud: HUD = null
var collectors: Spatial = null
var buildings: Spatial = null
var asteroid_info: AsteroidInfo = null

var mouse_hover_target = null
var mouse_selection_target = null
var mouse_cast_info: Dictionary = {}

# Currency
var fuel_amount = 0
var metal_amount = 0

# Game mode
var game_mode = GameMode.SELECTION
var building = null

# Gameplay
var asteroid_max_distance = 100000
var asteroid_speed = 12000
var asteroid_distance = asteroid_max_distance
var weapons = []
var asteroid_max_health = 2000
var asteroid_health = asteroid_max_health

var current_wave = -1


func _ready():
	game_mode = GameMode.CUTSCENE
	show_main_menu()
	pass
#	start_game()


func _physics_process(delta):
	if not game_mode == GameMode.CUTSCENE:
		mouse_cast_info = camera.mouse_3d_projection()
		if game_mode == GameMode.SELECTION:
			_check_cursor_hover()
			_check_cursor_click()
		else:
			if building:
				_building_snap_movement()
				_check_building_click()
			else:
				game_mode = GameMode.SELECTION
		_move_asteroid(delta)
		_update_currency_labels()
		_update_weapons()


func show_main_menu():
	for child in $Menus.get_children():
		child.queue_free()

	var menu = p_main_menu.instance()
	$Menus.add_child(menu)
	menu.connect("start_game", self, "show_lore_1_screen")


func show_lore_1_screen():
	for child in $Menus.get_children():
		child.queue_free()

	var menu = p_lore_1.instance()
	$Menus.add_child(menu)
	menu.connect("lore_next", self, "start_game")


func stop_game():
	game_mode = GameMode.CUTSCENE
	hud.fade_out(2.0)
	level.get_node("AnimationPlayer").play("Destruction")
	print("Loose")


func start_game():
	game_mode = GameMode.SELECTION
	for child in $Menus.get_children():
		child.queue_free()
	if level:
		level.queue_free()

	level = p_level.instance()
	var wait = add_child(level)

	camera = level.get_node("CustomCamera")
	camera.set_current(true)
	buildings = level.get_node("Buildings")
	hud = get_node("HUD")
#	collectors = level.get_node("Resources/Collectors")
#	grid = level.get_node("Grid")
	asteroid_info = hud.get_node("AsteroidInfo")

	_init_asteroid()
	hud.set_building_info(null)
	level.get_node("AnimationPlayer").play("Normal")

	weapons = []
	building = null

	mouse_hover_target = null
	mouse_selection_target = null
	mouse_cast_info = {}

	start_wave(0)


func start_wave(index: int):
	current_wave = index
	var wave_info = Global.WAVES[index]

	asteroid_max_distance = wave_info.max_distance
	asteroid_speed = wave_info.speed
	asteroid_distance = asteroid_max_distance
	asteroid_max_health = wave_info.max_health
	asteroid_health = asteroid_max_health

	_init_asteroid()


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
		"Building": mouse_selection_target.state = Global.SelectorState.NONE
	mouse_selection_target = null


func _unhover_current():
	if not mouse_hover_target:
		return
	match mouse_hover_target.get_class():
		"ResourceCollector": _unhover_resource_collector()
		"Cell": _unhover_cell()
		"Building": _unhover_building()
	mouse_hover_target = null

# ----- Gameplay -----

func _init_asteroid():
	asteroid_info.set_asteroid_max_distance(asteroid_max_distance)
	asteroid_info.set_asteroid_distance(asteroid_distance)
	asteroid_info.set_asteroid_max_health(asteroid_max_health)
	asteroid_info.set_asteroid_health(asteroid_max_health)


func _shoot_asteroid(damage: int):
	yield(get_tree().create_timer(DELAY_BEFORE_DAMAGE), "timeout")
	asteroid_health -= damage
	asteroid_health = clamp(asteroid_health, 0.0, asteroid_max_health)
	asteroid_info.set_asteroid_health(asteroid_health)
	print("Shoot asteroid: ", asteroid_health)
	if asteroid_health == 0:
		start_wave(current_wave + 1)


func _move_asteroid(delta):
	asteroid_distance -= asteroid_speed * delta
	asteroid_info.set_asteroid_distance(asteroid_distance)
	if asteroid_distance <= 0:
		stop_game()


func _update_currency_labels():
	hud.set_metal_amount(metal_amount)
	hud.set_fuel_amount(fuel_amount)


func _update_weapons():
	for weapon in weapons:
		var energy_required = weapon.get_energy_required()
		var energy_amount = weapon.get_energy_amount()
		if energy_amount < energy_required:
			weapon.building_state = Global.BuildingState.IDLE
			continue
		var attack_range = weapon.get_range()
		if asteroid_distance > attack_range:
			weapon.building_state = Global.BuildingState.IDLE
			continue
		weapon.building_state = Global.BuildingState.OPERATING

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
				"Building": _hovered_building()


func _check_cursor_click():
	var mouse_left_clicked = Input.is_action_just_pressed("mouse_left")
	var mouse_left_pressed = Input.is_action_pressed("mouse_left")
	var mouse_left_released = Input.is_action_just_released("mouse_left")

	if hud.is_mouse_over_hud():
		return
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
				"Building": _clicked_building()
		elif mouse_left_pressed:
			match mouse_hover_target.get_class():
				"ResourceCollector": _pressed_resource_collector()
				"Cell": _pressed_cell()
				"Building": _pressed_building()
		elif mouse_left_released:
			match mouse_hover_target.get_class():
				"ResourceCollector": _released_resource_collector()
				"Cell": _released_cell()
				"Building": _released_building()

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
	hud.set_building_info(null)
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

# ----- Building Stuff -----

func _hovered_building():
	match mouse_hover_target.state:

		Global.SelectorState.NONE:
			mouse_hover_target.state = Global.SelectorState.HOVERED

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED:
			mouse_hover_target.state = Global.SelectorState.HOVERED


func _clicked_building():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED:
			if not mouse_selection_target == mouse_hover_target:
				_unselect_current()
			mouse_selection_target = mouse_hover_target
			hud.set_building_info(mouse_selection_target)

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED:
#			if mouse_hover_target.building:
#				mouse_hover_target.state = Global.SelectorState.NONE
			pass


func _pressed_building():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _released_building():
	match mouse_hover_target.state:

		Global.SelectorState.NONE: pass

		Global.SelectorState.HOVERED: pass

		Global.SelectorState.CLICKED: pass

		Global.SelectorState.SELECTED: pass


func _unhover_building():
	if mouse_selection_target == mouse_hover_target:
		mouse_hover_target.state = Global.SelectorState.SELECTED
	else:
		mouse_hover_target.state = Global.SelectorState.NONE

# ----- Building System -----

func _building_snap_movement():
	var collider = mouse_cast_info.get("collider")

	if (
		not collider
		or not collider.get_class() in building.accepted_selector_classes
	):
		return

	var pos = collider.global_transform.origin

	pos.x -= int(Global.CELL_SIZE.x / 2)
	pos.y = Global.DEFAULT_BUILDING_HEIGHT
	pos.z += int(Global.CELL_SIZE.z / 2)

	building.global_transform.origin = pos


func _check_building_click():
	var mouse_left_click = Input.is_action_just_pressed("mouse_left")
	var mouse_right_click = Input.is_action_just_pressed("mouse_right")
	var cancel_action_click = Input.is_action_just_pressed("cancel_action")
	var collider = mouse_cast_info.get("collider")

	if hud.is_mouse_over_hud():
		return
	if mouse_left_click and collider in building.colliding_cells:
		if building.can_be_placed():
			building.place()

			if building.building_type == Building.BuildingType.WEAPON:
				weapons.append(building)
				building.connect("shoot", self, "_shoot_asteroid")

			building = null
			game_mode = GameMode.SELECTION
		else:
			pass
	elif mouse_right_click or cancel_action_click:
		building.queue_free()
		building = null
		game_mode = GameMode.SELECTION

# ----- GUI Integration -----

func _on_GUI_start_build(building_id):
	_unselect_current()
	if building:
		building.queue_free()
		building = null
	var building_info = Global.BUILDINGS.get(building_id)
	building = building_info.get("scene").instance()
	building.building_id = building_id
	building.building_state = Global.BuildingState.PLACING
	buildings.add_child(building)
	game_mode = GameMode.PLACING
