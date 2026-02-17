extends Node3D

@export var cam : Camera3D
@export var CarimboMesh : Node3D

func _physics_process(delta: float) -> void:
	var mousePos := get_viewport().get_mouse_position()

	var rayStart : Vector3= cam.project_ray_origin(mousePos)
	var direction : Vector3= cam.project_ray_normal(mousePos)

	var plane := Plane(Vector3.UP)

	var intersection = plane.intersects_ray(rayStart,direction)

	if intersection:
		CarimboMesh.global_position.x = intersection.x
		CarimboMesh.global_position.z = intersection.z
