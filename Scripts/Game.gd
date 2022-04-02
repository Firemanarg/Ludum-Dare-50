extends Node


var p_level = preload("res://Scenes/Level.tscn")

var level: Spatial = null
var camera: CustomCamera = null
var grid: Spatial = null

var mouse_3d = null
var mouse_hover_target = null
var mouse_selection_target = null

onready var o_cursor = get_node("Cursor")


func _ready():
	start_game()


func _physics_process(delta):
	if camera.is_inside_tree():
		var result: Dictionary = camera.cast_mouse_to_3d()
		if not result.empty():
			var collider = result.collider
			match collider.get_class():
				"CellSelector":
					set_hover_target(collider)
		else:
			set_hover_target(null)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if mouse_hover_target:
				set_selection_target(mouse_hover_target)
			else:
				set_selection_target(null)
	elif event is InputEventKey:
		match event.scancode:
			KEY_1:
				camera.set_state(camera.ZoomState.GRID_VIEW)
			KEY_2:
				camera.set_state(camera.ZoomState.NORMAL)
			KEY_3:
				camera.set_state(camera.ZoomState.SKY_VIEW)


func set_hover_target(target):
	if mouse_hover_target:
		if mouse_hover_target.has_method("unhover"):
			mouse_hover_target.unhover()
	mouse_hover_target = target
	if target and target.has_method("hover"):
		target.hover()


func set_selection_target(target):
	if mouse_selection_target:
		if mouse_selection_target.has_method("unselect"):
			mouse_selection_target.unselect()
	mouse_selection_target = target
	if target and target.has_method("select"):
		target.select()


func start_game():
	if level:
		level.queue_free()
	level = p_level.instance()
	add_child(level)
	camera = level.get_node("CustomCamera")
	grid = level.get_node("Grid")
