extends Node3D

@export var cam : Camera3D
@export var ObjectNode3D : Node3D = null
@export var previsao : Sprite3D
@export var Carimbada : Texture2D
@export var ray : RayCast3D
var posInicial : Vector3
@export var posDecal : Vector3
static var holding : bool = false

func _selecionar_novo_objeto(alvo):
	holding = true
	posInicial = alvo.global_position
	alvo.global_position.y += 0.25
	ObjectNode3D = alvo
	previsao.visible = true

func _desselecionar_objeto(alvo):
	holding = false
	alvo.global_position = posInicial
	ObjectNode3D = null
	previsao.visible = false

func _physics_process(_delta):
	if not ObjectNode3D:
		return

	var mousePos = get_viewport().get_mouse_position()
	var rayStart = cam.project_ray_origin(mousePos)
	var direction = cam.project_ray_normal(mousePos)
	
	var plane = Plane(Vector3.UP, ObjectNode3D.global_position.y) #limitei o y...
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
			if event.button_index == MOUSE_BUTTON_LEFT:
				_carimbar()
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				_desselecionar_objeto(self)

func _carimbar():
	if not ray.is_colliding():
		return
		
	var novo_decalque = Decal.new()
	novo_decalque.texture_albedo = Carimbada
	novo_decalque.size = posDecal
	novo_decalque.size.y = 2.0
	novo_decalque.cull_mask = 1

	var collider = ray.get_collider()
	collider.add_child(novo_decalque)
	
	novo_decalque.global_position = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	_alinhar_decalque(novo_decalque, normal)

func _alinhar_decalque(decal, normal):
	if normal.is_equal_approx(Vector3.UP):
		decal.rotation_degrees.x = 0
	elif normal.is_equal_approx(Vector3.DOWN):
		decal.rotation_degrees.x = 180
	else:
		decal.look_at(decal.global_position - normal, Vector3.UP)
