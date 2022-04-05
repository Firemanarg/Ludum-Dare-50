extends Control


signal lore_next()

onready var o_label_text = get_node("CenterContainer/LabelText")
onready var o_tween = get_node("Tween")


func _ready():
	show_text(8)
	$Timer.start(11)


func show_text(duration: float):
	o_tween.interpolate_property(
		o_label_text,
		"percent_visible",
		0.0,
		1.0,
		duration
	)
	o_tween.stop_all()
	o_tween.start()


func _on_Timer_timeout():
	emit_signal("lore_next")
