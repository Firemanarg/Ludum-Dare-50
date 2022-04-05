tool
extends StaticBody
class_name Building


enum BuildingType {
	GENERATOR,
	WEAPON,
}

const DEFAULT_SHAPE_HEIGHT = 0.25

export(BuildingType) var building_type = BuildingType.WEAPON
export(Vector2) var size = Vector2(1, 1)
export(PoolStringArray) var accepted_selector_classes = []

var colliding_cells = []
var building_id = Global.BuildingID.UNKNOWN

var building_state = Global.BuildingState.IDLE
var state = Global.SelectorState.NONE
var _last_building_state = null
var _last_state = null


func _ready():
	var mat = $VisualSelector.get_surface_material(0)
	$VisualSelector.set_surface_material(0, mat.duplicate())
	$CollisionShape.shape = $CollisionShape.shape.duplicate()
	$CellDetection/CollisionShape.shape = $CellDetection/CollisionShape.shape.duplicate()
	$VisualSelector.mesh = $VisualSelector.mesh.duplicate()
	if Engine.editor_hint:
		set_visual_config(Global.BUILDING_HOVERED_CONFIG)
	else:
		state = Global.SelectorState.NONE
	_update_base()


func _physics_process(delta):
	if Engine.editor_hint:
		_update_base()

	else:
		if not building_state == _last_building_state:
			_last_building_state = building_state

		match building_state:

			Global.BuildingState.IDLE: _state_idle()
			Global.BuildingState.OPERATING: _state_operating()
			Global.BuildingState.PLACING: _state_placing()

		if not state == _last_state:
			match state:
				Global.SelectorState.NONE: _state_none()
				Global.SelectorState.HOVERED: _state_hovered()
				Global.SelectorState.SELECTED: _state_selected()
			_last_state = state


func get_class() -> String:
	return "Building"


func can_be_placed() -> bool:
	var check_size = colliding_cells.size() == int(size.x * size.y)
	if check_size:
		for cell in colliding_cells:
			if cell.building:
				return false
		return true
	else:
		return false


func set_visual_config(config: Dictionary):
	var mat = $VisualSelector.get_surface_material(0)
	var ratio = (size.x + size.y) / 2.0

	mat.set_shader_param("scan_color", config["scan_color"])
	mat.set_shader_param("scan_line_width", config["scan_line_width"])
	mat.set_shader_param("scan_line_size", config["scan_line_size"] / ratio)
	mat.set_shader_param("shift", config["shift"] / ratio)
	mat.set_shader_param("time_shift_scale", config["time_shift_scale"] / ratio)
	$VisualSelector.set_surface_material(0, mat)


func place():
	for cell in colliding_cells:
		cell.building = self
	building_state = Global.BuildingState.IDLE
	state = Global.SelectorState.NONE
	set_visual_config(Global.NONE_CONFIG)
	pass

# ----- Getters -----

func get_building_name() -> String:
	var value = Global.BUILDINGS.get(building_id).name
	return value


func get_description() -> String:
	var value = Global.BUILDINGS.get(building_id).description
	return value


func get_building_scene():
	var value = Global.BUILDINGS.get(building_id).scene
	return value


func get_icon():
	var value = Global.BUILDINGS.get(building_id).icon
	return value


func get_metal_cost() -> int:
	var value = Global.BUILDINGS.get(building_id).metal
	return value


func get_fuel_cost() -> int:
	var value = Global.BUILDINGS.get(building_id).fuel
	return value


func get_energy_required() -> int:
	var value = Global.BUILDINGS.get(building_id).energy_required
	return value


func get_energy_amount() -> int:
	return 0


func get_energy_produced() -> int:
	var value = Global.BUILDINGS.get(building_id).energy_produced
	return value


func get_range() -> int:
	var value = Global.BUILDINGS.get(building_id).range
	return value


func get_damage() -> int:
	var value = Global.BUILDINGS.get(building_id).damage
	return value


func get_cooldown() -> float:
	var value = float(Global.BUILDINGS.get(building_id).cooldown)
	return value

# ----- Building States -----

func _state_idle():
	$CollisionShape.disabled = false


func _state_operating():
	$CollisionShape.disabled = false


func _state_placing():
	$CollisionShape.disabled = true
	state = Global.SelectorState.NONE
	if can_be_placed():
		set_visual_config(Global.BUILDING_PLACING_ALLOW_CONFIG)
	else:
		set_visual_config(Global.BUILDING_PLACING_DENY_CONFIG)


# ----- Selector States -----

func _state_none():
	if not building_state == Global.BuildingState.PLACING:
		set_visual_config(Global.NONE_CONFIG)


func _state_hovered():
	if not building_state == Global.BuildingState.PLACING:
		set_visual_config(Global.BUILDING_HOVERED_CONFIG)


func _state_selected():
	if not building_state == Global.BuildingState.PLACING:
		set_visual_config(Global.BUILDING_SELECTED_CONFIG)

# ----- Update -----

func _update_base():

	# Update Shape
	$CollisionShape.shape.extents.x = size.x
	$CollisionShape.shape.extents.y = DEFAULT_SHAPE_HEIGHT
	$CollisionShape.shape.extents.z = size.y
	$CollisionShape.translation = Vector3(
		size.x,
		DEFAULT_SHAPE_HEIGHT,
		-size.y
	)

	# Update Mesh
	$Mesh.translation = Vector3(
		size.x,
		0,
		-size.y
	)

	# Cell Detection
	$CellDetection/CollisionShape.shape.extents.x = size.x - 0.2
	$CellDetection/CollisionShape.shape.extents.y = DEFAULT_SHAPE_HEIGHT
	$CellDetection/CollisionShape.shape.extents.z = size.y - 0.2
	$CellDetection.translation = Vector3(
		size.x,
		-DEFAULT_SHAPE_HEIGHT,
		-size.y
	)

	# Visual Selector
	$VisualSelector.translation = Vector3(
		size.x,
		0,
		-size.y
	)
	$VisualSelector.scale = Vector3(
		size.x + 0.2,
		1,
		size.y + 0.2
	)

# ----- Slots -----

func _on_CellDetection_body_entered(body):
	if body.get_class() in accepted_selector_classes:
		colliding_cells.append(body)


func _on_CellDetection_body_exited(body):
	if body.get_class() in accepted_selector_classes:
		colliding_cells.erase(body)
