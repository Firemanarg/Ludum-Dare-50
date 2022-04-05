tool
extends Building


signal shoot(damage)


func _ready():
	pass


func _physics_process(delta):
	_update_energy_detection()


func get_energy_amount() -> int:
	var energy_amount = 0
	var collisions = $EnergyDetection.get_overlapping_areas()
	for collision in collisions:
		var generator = collision.get_parent()
		energy_amount += generator.get_energy_produced()
	return energy_amount


func can_shoot() -> bool:
	return $TimerCooldown.time_left == 0


func _shoot():
	for pos in $ShootPositions.get_children():
		var bullet = Global.PRELOADS.bullet.instance()

		pos.add_child(bullet)

	$TimerCooldown.start(get_cooldown())
	emit_signal("shoot", get_damage())
	print("Shoot")


func _update_energy_detection():
	$EnergyDetection/CollisionShape.shape.extents.x = size.x - 0.1
	$EnergyDetection/CollisionShape.shape.extents.y = DEFAULT_SHAPE_HEIGHT
	$EnergyDetection/CollisionShape.shape.extents.z = size.y - 0.1
	$EnergyDetection.translation = Vector3(
		size.x,
		DEFAULT_SHAPE_HEIGHT * 3,
		-size.y
	)

# ----- Building States

func _state_idle():
	._state_operating()


func _state_operating():
	._state_operating()
	if can_shoot():
		_shoot()


func _state_placing():
	._state_placing()

# ----- Selector States -----

func _state_none():
	._state_none()


func _state_hovered():
	._state_hovered()


func _state_selected():
	._state_selected()
