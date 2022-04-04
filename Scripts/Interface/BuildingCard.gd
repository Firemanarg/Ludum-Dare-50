extends PanelContainer
class_name BuildingCard


signal pressed(id)

const NORMAL_COLOR = Color(0.6, 0.6, 0.6, 0.33)
const HOVERED_COLOR = Color(1, 1, 1, 0.33)
const PRESSED_COLOR = Color(0, 0, 0, 0.33)

export(Global.BuildingID) var building_id = Global.BuildingID.UNKNOWN

var target_scene = null

onready var o_label = {
	"name": get_node("MarginContainer/VBoxContainer/LabelName"),
	"metal": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerMetal/LabelValueMetal"),
	"fuel": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerFuel/LabelValueFuel"),
	"energy_required": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerEnergyRequired/LabelValueEnergyRequired"),
	"energy_produced": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerEnergyProduction/LabelValueEnergyProduction"),
	"range": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerRange/LabelValueRange"),
	"damage": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerDamage/LabelValueDamage"),
	"cooldown": get_node("MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/GridContainer/HBoxContainerCooldown/LabelValueCooldown"),
}
onready var o_icon = get_node("MarginContainer/VBoxContainer/HBoxContainer/TextureRectIcon")


func _ready():
	var panel = get("custom_styles/panel")
	set("custom_styles/panel", panel.duplicate())
	update_card_info()

func _process(delta):
	pass


func update_card_info():
	var building_info: Dictionary = Global.BUILDINGS.get(building_id)

	for key in building_info.keys():
		if key in ["description", "scene", "icon"]:
			 continue
		o_label[key].text = str(building_info[key])
		if not key == "name":
			if building_info[key] == 0:
				o_label[key].get_parent().visible = false
			else:
				o_label[key].get_parent().visible = true
	target_scene = building_info.get("scene")
	o_icon.texture = building_info.get("icon").duplicate()
	o_icon.hint_tooltip = building_info.get("description")


func set_bg_color(color: Color):
	var panel = get("custom_styles/panel")
	panel.bg_color = color
	set("custom_styles/panel", panel)


func _on_BuildingCard_mouse_entered():
	set_bg_color(HOVERED_COLOR)


func _on_BuildingCard_mouse_exited():
	set_bg_color(NORMAL_COLOR)


func _on_BuildingCard_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				set_bg_color(PRESSED_COLOR)
				emit_signal("pressed", building_id)
				print("Pressed emitted")
			else:
				set_bg_color(HOVERED_COLOR)
