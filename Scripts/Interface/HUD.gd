extends CanvasLayer
class_name HUD


signal start_build(building_id)

var _is_mouse_over_hud = false
var _is_menu_active = false

onready var o_tween = get_node("Tween")
onready var o_building_menu = get_node("Building/BuildingMenu")
onready var o_container_building_cards = get_node("Building/BuildingMenu/ScrollContainer/ContainerBuildingCards")
onready var o_metal_amount_label = get_node("Panel/MarginContainer/HBoxContainer/HBoxContainerMetal/VBoxContainer/MetalAmountLabel")
onready var o_fuel_amount_label = get_node("Panel/MarginContainer/HBoxContainer/HBoxContainerFuel/VBoxContainer/FuelAmountLabel")


func _ready():
	_animate_building_menu(Vector2(0, 0), Vector2(0, 0), 0.0)
	for card in o_container_building_cards.get_children():
		card.connect("pressed", self, "_on_BuildingCard_pressed")


func is_mouse_over_hud() -> bool:
	return _is_mouse_over_hud


func set_metal_amount(value):
	o_metal_amount_label.text = str(value)


func set_fuel_amount(value):
	o_fuel_amount_label.text = str(value)


func _mouse_entered_hud():
	_is_mouse_over_hud = true


func _mouse_exited_hud():
	_is_mouse_over_hud = false


func _animate_building_menu(
	in_scale: Vector2,
	out_scale: Vector2,
	duration: float
):
	o_tween.interpolate_property(
		o_building_menu,
		"rect_scale",
		in_scale,
		out_scale,
		duration,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	o_tween.stop_all()
	o_tween.start()


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


func _on_Panel_mouse_exited():
	_mouse_exited_hud()


func _on_BuildingMenu_mouse_exited():
	_mouse_exited_hud()


func _on_Building_mouse_exited():
	_mouse_exited_hud()
