extends CanvasLayer


signal start_build(building_id)

var _is_menu_active = false

onready var o_tween = get_node("Tween")
onready var o_building_menu = get_node("Building/BuildingMenu")
onready var o_container_building_cards = get_node("Building/BuildingMenu/ScrollContainer/ContainerBuildingCards")


func _ready():
	_animate_building_menu(Vector2(0, 0), Vector2(0, 0), 0.0)
	for card in o_container_building_cards.get_children():
		card = card as BuildingCard
		card.connect("pressed", self, "_on_BuildingCard_pressed")


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
