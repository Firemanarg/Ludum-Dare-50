extends CanvasLayer
class_name HUD


signal start_build(building_id)

var _is_mouse_over_hud = false
var _is_menu_active = false

onready var o_tween_fade = get_node("TweenFade")
onready var o_tween_building_menu = get_node("TweenBuildingMenu")
onready var o_tween_building_info = get_node("TweenBuildingInfo")
onready var o_building_menu = get_node("Building/BuildingMenu")
onready var o_container_building_cards = get_node("Building/BuildingMenu/ScrollContainer/ContainerBuildingCards")
onready var o_metal_amount_label = get_node("Panel/MarginContainer/HBoxContainer/HBoxContainerMetal/VBoxContainer/MetalAmountLabel")
onready var o_fuel_amount_label = get_node("Panel/MarginContainer/HBoxContainer/HBoxContainerFuel/VBoxContainer/FuelAmountLabel")
onready var o_info_building_name = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/LabelName")
onready var o_info_energy_required = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo/VBoxContainer/HBoxContainerEnergyRequired/LabelValueEnergyRequired")
onready var o_info_energy_produced = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo/VBoxContainer/HBoxContainerEnergyProduction/LabelValueEnergyProduction")
onready var o_info_range = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo/VBoxContainer/HBoxContainerRange/LabelValueRange")
onready var o_info_damage = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo/VBoxContainer2/HBoxContainerDamage/LabelValueDamage")
onready var o_info_cooldown = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo/VBoxContainer2/HBoxContainerCooldown/LabelValueCooldown")
onready var o_container_building_info = get_node("Building/BuildingInfo/MarginContainer/VBoxContainer/ContainerBuildingInfo")


func _ready():
	_animate_building_menu(Vector2(0, 0), Vector2(0, 0), 0.0)
	for card in o_container_building_cards.get_children():
		card.connect("pressed", self, "_on_BuildingCard_pressed")


func fade_in(duration: float = 1.0):
	for node in get_children():
		if node.get("modulate"):
			var md: Color = node.modulate
			md.a = 0.0
			var target: Color = md
			target.a = 1.0
			o_tween_fade.interpolate_property(
				node,
				"modulate",
				md,
				target,
				duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN
			)
	o_tween_fade.stop_all()
	o_tween_fade.start()
	pass


func fade_out(duration: float = 1.0):
	for node in get_children():
		if node.get("modulate"):
			var md: Color = node.modulate
			md.a = 1.0
			var target: Color = md
			target.a = 0.0
			o_tween_fade.interpolate_property(
				node,
				"modulate",
				md,
				target,
				duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN
			)
	o_tween_fade.stop_all()
	o_tween_fade.start()
	pass


func is_mouse_over_hud() -> bool:
	return _is_mouse_over_hud


func set_metal_amount(value):
	o_metal_amount_label.text = str(value)


func set_fuel_amount(value):
	o_fuel_amount_label.text = str(value)


func set_building_info(building):
	if not building:
		o_container_building_info.visible = false
		o_info_building_name.text = "No Building Selected!"
		return
	o_container_building_info.visible = true

	var building_name = building.get_building_name()
	var energy_required = building.get_energy_required()
	var energy_amount = building.get_energy_amount()
	var energy_produced = building.get_energy_produced()
	var building_range = building.get_range()
	var damage = building.get_damage()
	var cooldown = building.get_cooldown()

	o_info_building_name.text = building_name
	if energy_required > 0:
		o_info_energy_required.get_parent().visible = true
		o_info_energy_required.text = (
			str(energy_amount) + " / " + str(energy_required)
		)
	else:
		o_info_energy_required.get_parent().visible = false
	if energy_produced > 0:
		o_info_energy_produced.get_parent().visible = true
		o_info_energy_produced.text = str(energy_produced)
	else:
		o_info_energy_produced.get_parent().visible = false
	o_info_range.text = str(building_range)
	o_info_damage.text = str(damage)
	o_info_cooldown.text = str(cooldown)


func _mouse_entered_hud():
	_is_mouse_over_hud = true


func _mouse_exited_hud():
	_is_mouse_over_hud = false


func _animate_building_menu(
	in_scale: Vector2,
	out_scale: Vector2,
	duration: float
):
	o_tween_building_menu.interpolate_property(
		o_building_menu,
		"rect_scale",
		in_scale,
		out_scale,
		duration,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	o_tween_building_menu.stop_all()
	o_tween_building_menu.start()


func _on_ButtonBuilding_pressed():
	if not _is_menu_active:
		_animate_building_menu(o_building_menu.rect_scale, Vector2(1, 1), 0.5)
		_is_menu_active = true
	else:
		_animate_building_menu(o_building_menu.rect_scale, Vector2(0, 0), 0.5)
		_is_menu_active = false
#	emit_signal("start_build", Global.BuildingID.TEST)


func _on_BuildingCard_pressed(id):
	emit_signal("start_build", id)


func _on_Panel_mouse_entered():
	_mouse_entered_hud()


func _on_BuildingMenu_mouse_entered():
	_mouse_entered_hud()


func _on_Building_mouse_entered():
	_mouse_entered_hud()


func _on_BuildingInfo_mouse_entered():
	_mouse_entered_hud()


func _on_PanelUpgrade_mouse_entered():
	_mouse_entered_hud()


func _on_PanelDestroy_mouse_entered():
	_mouse_entered_hud()


func _on_Panel_mouse_exited():
	_mouse_exited_hud()


func _on_BuildingMenu_mouse_exited():
	_mouse_exited_hud()


func _on_Building_mouse_exited():
	_mouse_exited_hud()


func _on_BuildingInfo_mouse_exited():
	_mouse_exited_hud()


func _on_PanelUpgrade_mouse_exited():
	_mouse_exited_hud()


func _on_PanelDestroy_mouse_exited():
	_mouse_exited_hud()
