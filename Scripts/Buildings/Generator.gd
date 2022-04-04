tool
extends Building

onready var o_energy_area = get_node("EnergyArea")


func _ready():
	pass

# ----- Building States

func _state_idle():
	._state_operating()


func _state_operating():
	._state_operating()


func _state_placing():
	._state_placing()
	o_energy_area.visible = true

# ----- Selector States -----

func _state_none():
	._state_none()
	o_energy_area.visible = false


func _state_hovered():
	._state_hovered()
	o_energy_area.visible = true


func _state_selected():
	._state_selected()
	o_energy_area.visible = true
