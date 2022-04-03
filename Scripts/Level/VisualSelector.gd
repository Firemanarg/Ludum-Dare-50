tool
extends Spatial
class_name VisualSelector


export(Vector3) var size = Vector3(1, 1, 1)
export(float) var thickness = 0.15


func _ready():
	pass


func _physics_process(delta):
	if Engine.editor_hint:
		_update_size()


func set_color(color: Color):
	$Mesh.material_override.set_shader_param("barrier_color", color)


func _update_size():
	_set_csg_mesh_size($Mesh/OuterMesh, size)
	_set_csg_mesh_size($Mesh/InnerMesh, size - size * thickness)
	$Mesh/InnerMesh.height = size.y + 0.1

	$Mesh.translation.y = size.y / 2.0


func _set_csg_mesh_size(mesh, mesh_size: Vector3):
	mesh.width = mesh_size.x
	mesh.height = mesh_size.y
	mesh.depth = mesh_size.z
