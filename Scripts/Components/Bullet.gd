extends MeshInstance


const SPEED = 40
const LIFETIME = 10

var _timer = 0


func _ready():
	pass


func _physics_process(delta):
	_timer += delta
	if _timer > LIFETIME:
		queue_free()
	else:
		translation.x -= SPEED * delta
