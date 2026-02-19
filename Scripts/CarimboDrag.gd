extends Node3D

@export var cam : Camera3D
@export var ObjectNode3D : Node3D = null

func _selecionar_novo_objeto(alvo):
	ObjectNode3D = alvo
	print("Segurando: ", alvo.name)

func _desselecionar_objeto(alvo):
	ObjectNode3D = null
	print("Dessegurando: ", alvo.name)
	# Voltar pra posicao inicial

func _physics_process(_delta):
	if not ObjectNode3D:
		return

	var mousePos = get_viewport().get_mouse_position()
	var rayStart = cam.project_ray_origin(mousePos)
	var direction = cam.project_ray_normal(mousePos)
	
	var plane = Plane(Vector3.UP)
	var intersection = plane.intersects_ray(rayStart, direction)

	if intersection:
		ObjectNode3D.global_position.x = intersection.x
		ObjectNode3D.global_position.z = intersection.z

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_selecionar_novo_objeto(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_desselecionar_objeto(self)
