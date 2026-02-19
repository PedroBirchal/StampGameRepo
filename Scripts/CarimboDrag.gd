extends Node3D

@export var cam : Camera3D
@export var ObjectNode3D : Node3D = null
@export var previsao : Sprite3D
var posInicial : Vector3
static var holding : bool = false

func _selecionar_novo_objeto(alvo):
	holding = true
	posInicial = alvo.global_position
	alvo.global_position.y += 0.1
	ObjectNode3D = alvo
	print("Segurando: ", alvo.name)
	previsao.visible = true

func _desselecionar_objeto(alvo):
	holding = false
	alvo.global_position = posInicial
	ObjectNode3D = null
	previsao.visible = false
	print("Dessegurando: ", alvo.name)

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
			if holding:
				return
			else: 
				_selecionar_novo_objeto(self)

func _input(event):	
	if ObjectNode3D == self:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				_desselecionar_objeto(self)
