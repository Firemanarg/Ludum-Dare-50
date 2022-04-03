tool
extends StaticBody
class_name CellSelector


const HOVER_COLOR = Color(0, 0.9, 1)
const SELECTED_COLOR = Color(0, 0.1, 1)
const UNAVAILABLE_COLOR = Color(0.5, 0, 0)

enum Direction {
	UP = -1,
	DOWN = 1,
}

export(bool) var collisions_enabled = true

var is_hovered = false
var is_selected = false

var target = null
var _selection_shape_size = Vector3(1, 1, 1)
var _visual_selector_outer_size = Vector3(2, 0.6, 2)
var _visual_selector_inner_size = Vector3(1.5, 0.7, 1.5)
var _visual_selector_offset = Vector3(0, -0.6, 0)



func _ready():
	$CollisionShape.shape = $CollisionShape.shape.duplicate()
	if Engine.editor_hint:
		$Tmp.mesh = $Tmp.mesh.duplicate()
	else:
		_update_position_and_size()
		$Tmp.queue_free()
		unhover()
		unselect()


func _process(delta):
	if Engine.editor_hint:
		_update_position_and_size()


func get_class() -> String:
	return "CellSelector"


func set_collisions_enabled(state: bool):
	collisions_enabled = state
	$CollisionShape.disabled = not collisions_enabled


func hover():
	is_hovered = true
	if not is_selected:
		$VisualSelector.visible = true
		set_selector_color(HOVER_COLOR)
		set_animation_direction(Direction.DOWN)


func unhover():
	is_hovered = false
	if not is_selected:
		$VisualSelector.visible = false
	else:
		select()


func select():
	is_selected = true
	$VisualSelector.visible = true
	set_selector_color(SELECTED_COLOR)
	set_animation_direction(Direction.UP)


func unselect():
	is_selected = false
	if not is_hovered:
		$VisualSelector.visible = false
	else:
		hover()


func set_selector_color(color: Color):
	var material: ShaderMaterial = $VisualSelector.material_override.duplicate()
	material.set_shader_param("barrier_color", color)
	$VisualSelector.material_override = material


func set_animation_direction(direction: int):
	var material: ShaderMaterial = $VisualSelector.material_override.duplicate()
	var speed = material.get_shader_param("barrier_speed")
	material.set_shader_param("barrier_speed", abs(speed) * direction)
	$VisualSelector.material_override = material


func _update_position_and_size():
	$CollisionShape.shape.extents = _selection_shape_size
	$Tmp.mesh.size = _selection_shape_size * 2
	$VisualSelector.translation = _visual_selector_offset
	$VisualSelector/VisualSelectorOuter.width = _visual_selector_outer_size.x
	$VisualSelector/VisualSelectorOuter.height = _visual_selector_outer_size.y
	$VisualSelector/VisualSelectorOuter.depth = _visual_selector_outer_size.z
	$VisualSelector/VisualSelectorInner.width = _visual_selector_inner_size.x
	$VisualSelector/VisualSelectorInner.height = _visual_selector_inner_size.y
	$VisualSelector/VisualSelectorInner.depth = _visual_selector_inner_size.z


func _get(property):
	match property:
		"selection_shape/size": return _selection_shape_size
		"visual_selector/outer_size": return _visual_selector_outer_size
		"visual_selector/inner_size": return _visual_selector_inner_size
		"visual_selector/offset": return _visual_selector_offset


func _set(property, value):
	match property:
		"selection_shape/size": _selection_shape_size = value
		"visual_selector/outer_size": _visual_selector_outer_size = value
		"visual_selector/inner_size": _visual_selector_inner_size = value
		"visual_selector/offset": _visual_selector_offset = value
	return false


func _get_property_list():
	var properties = []
	properties.append({
		"name": "selection_shape/size",
		"type": TYPE_VECTOR3,
	})
	properties.append({
		"name": "visual_selector/outer_size",
		"type": TYPE_VECTOR3,
	})
	properties.append({
		"name": "visual_selector/inner_size",
		"type": TYPE_VECTOR3,
	})
	properties.append({
		"name": "visual_selector/offset",
		"type": TYPE_VECTOR3,
	})
	return properties
