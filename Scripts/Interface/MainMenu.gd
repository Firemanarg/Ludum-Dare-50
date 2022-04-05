extends Control


signal start_game()

var _space_rotation_speed = 1
var _stars1_rotation_speed = -2
var _stars2_rotation_speed = 2

onready var o_texture_space = get_node("TextureRectSpace")
onready var o_texture_stars1 = get_node("TextureRectStars1")
onready var o_texture_stars2 = get_node("TextureRectStars2")


func _ready():
	pass


func _process(delta):
	o_texture_space.rect_rotation += _space_rotation_speed * delta
	o_texture_stars1.rect_rotation += _stars1_rotation_speed * delta
	o_texture_stars2.rect_rotation += _stars2_rotation_speed * delta


func _on_ButtonStart_pressed():
	emit_signal("start_game")
