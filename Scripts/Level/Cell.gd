tool
extends StaticBody
class_name Cell


var building = null
var state = Global.SelectorState.NONE
var _last_state = null


func _ready():
	var mat = $VisualSelector.get_surface_material(0)
	$VisualSelector.set_surface_material(0, mat.duplicate())
	if Engine.editor_hint:
		set_visual_config(Global.CELL_HOVERED_CONFIG)
	else:
		state = Global.SelectorState.NONE


func _physics_process(delta):
	if not Engine.editor_hint:
		if not state == _last_state:
			match state:
				Global.SelectorState.NONE: _state_none()
				Global.SelectorState.HOVERED: _state_hovered()
				Global.SelectorState.CLICKED: _state_clicked()
				Global.SelectorState.SELECTED: _state_selected()

			_last_state = state


func get_class() -> String:
	return "Cell"


func set_visual_config(config: Dictionary):
	var mat = $VisualSelector.get_surface_material(0)
	for param in config.keys():
		var value =  config[param]
		mat.set_shader_param(param, value)
	$VisualSelector.set_surface_material(0, mat)


func _state_none():
	set_visual_config(Global.NONE_CONFIG)


func _state_hovered():
	set_visual_config(Global.CELL_HOVERED_CONFIG)


func _state_selected():
	set_visual_config(Global.CELL_SELECTED_CONFIG)


func _state_clicked():
	set_visual_config(Global.CELL_CLICKED_CONFIG)
