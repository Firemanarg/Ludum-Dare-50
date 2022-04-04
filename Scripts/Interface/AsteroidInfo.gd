tool
extends Control
class_name AsteroidInfo


const MAX_COLOR = Color(0.329412, 1, 0.329412)
const MIN_COLOR = Color(2, 0.329412, 0.329412)

export var _asteroid_distance = 100

var rotation_speed = 10
var _asteroid_max_distance = 100


func _ready():
	$Asteroid.rect_rotation = 0


func _process(delta):
	_update_asteroid_position()
	_update_bar()
	_update_label()
	$Asteroid.rect_rotation += rotation_speed * delta


func set_asteroid_max_distance(value: int):
	_asteroid_max_distance = value
	$ProgressBar.max_value = _asteroid_max_distance


func set_asteroid_distance(value: int):
	_asteroid_distance = value


func _update_asteroid_position():
	var bar_pos = $ProgressBar.rect_position
	var bar_size = $ProgressBar.rect_size
	var percent = float(_asteroid_distance) / _asteroid_max_distance
	$Asteroid.rect_position.x = lerp(
		bar_pos.x,
		bar_pos.x + bar_size.x,
		percent
	) - ($Asteroid.rect_size.x / 2.0)


func _update_bar():
	var percent = float(_asteroid_distance) / _asteroid_max_distance
	var color = lerp(MIN_COLOR, MAX_COLOR, percent)
	var fg = $ProgressBar.get("custom_styles/fg")

	fg.bg_color = color
	$ProgressBar.set("custom_styles/fg", fg)

	$ProgressBar.value = _asteroid_distance


func _update_label():
	$LabelDistance.text = "Distance: " + str(_asteroid_distance)
