extends StaticBody
class_name Cell


var slot_target = null


func _ready():
	pass


func is_occupied() -> bool:
	return not slot_target == null
