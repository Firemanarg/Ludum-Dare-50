tool
extends StaticBody
class_name ResourceCollector


enum State {
	NONE,
	HOVERED,
	SELECTED,
	CLICKED,
}

enum ResourceType {
	FUEL,
	METAL,
}

const NONE_CONFIG = {
	"scan_color": Color(0, 0, 0),
	"scan_line_width": 0,
	"scan_line_size": 0,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0, 0, 0),
}
const HOVERED_CONFIG = {
	"scan_color": Color(0.078431, 1, 1),
	"scan_line_width": 0.6,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.3, 0.3),
}
const SELECTED_CONFIG = {
	"scan_color": Color(0.784314, 0.196078, 0.196078),
	"scan_line_width": 0.3,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.1, -0.1, 0.1),
}
const CLICKED_CONFIG = {
	"scan_color": Color(1, 1, 0),
	"scan_line_width": 0.6,
	"scan_line_size": 0.2,
	"shift": Vector3(0, 0, 0),
	"time_shift_scale": Vector3(0.3, -0.3, 0.3),
}

export(ResourceType) var resource_type = ResourceType.FUEL
export(int) var production_amount = 42

var building = null
var state = State.NONE
var _last_state = State.NONE


func _ready():
	var mat = $VisualSelector.get_surface_material(0)
	$VisualSelector.set_surface_material(0, mat.duplicate())
	if Engine.editor_hint:
		set_visual_config(HOVERED_CONFIG)
	else:
		state = State.NONE
		set_visual_config(NONE_CONFIG)


func _physics_process(delta):
	if not Engine.editor_hint:
		if not state == _last_state:
			match state:
				State.NONE: _state_none()
				State.HOVERED: _state_hovered()
				State.CLICKED: _state_clicked()
				State.SELECTED: _state_selected()

			_last_state = state


func get_class() -> String:
	return "ResourceCollector"


func set_visual_config(config: Dictionary):
	for param in config.keys():
		var mat = $VisualSelector.get_surface_material(0)
		var value =  config[param]
		mat.set_shader_param(param, value)
		$VisualSelector.set_surface_material(0, mat)


func _state_none():
	set_visual_config(NONE_CONFIG)


func _state_hovered():
	set_visual_config(HOVERED_CONFIG)


func _state_selected():
	set_visual_config(SELECTED_CONFIG)


func _state_clicked():
	set_visual_config(CLICKED_CONFIG)
