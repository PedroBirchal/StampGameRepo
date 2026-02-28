extends Node3D

@export var cam : Camera3D
@export var ObjectNode3D : Node3D = null
@export var previsao : Sprite3D
@export var Carimbada : Texture2D
@export var ray : RayCast3D
var posInicial : Vector3
static var holding : bool = false
static var ehCaixa : bool = false
static var decal_size : Vector3 = Vector3(0.5, 0.04, 0.5)

func _selecionar_novo_objeto(alvo):
	holding = true
	posInicial = alvo.global_position
	alvo.global_position.y += 0.3
		
	if ehCaixa:
		alvo.global_rotate(Vector3.LEFT, 80)
		alvo.global_position.z += 1.2
	ObjectNode3D = alvo
	previsao.visible = true

func _desselecionar_objeto(alvo):
	holding = false
	alvo.global_position = posInicial
		
	if ehCaixa:
		alvo.global_rotate(Vector3.LEFT, -80)
	ObjectNode3D = null
	previsao.visible = false
	
func _physics_process(_delta):
	if not ObjectNode3D:
		return

	var mousePos = get_viewport().get_mouse_position()
	var rayStart = cam.project_ray_origin(mousePos)
	var direction = cam.project_ray_normal(mousePos)
	
	var plane : Plane
	if ehCaixa:
		plane = Plane(Vector3(0, 0, 1), ObjectNode3D.global_position.z)
	else:
		plane = Plane(Vector3.UP, ObjectNode3D.global_position.y)
	
	var intersection = plane.intersects_ray(rayStart, direction)

	if intersection:
		if ehCaixa:
			ObjectNode3D.global_position.x = intersection.x
			ObjectNode3D.global_position.y = intersection.y
		else:
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
		
	var collider = ray.get_collider()
	var ponto = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	print("collider: ", collider.name)

	var novo_decalque = Decal.new()
	novo_decalque.texture_albedo = Carimbada
	novo_decalque.size = decal_size
	novo_decalque.cull_mask = 1
	
	collider.add_child(novo_decalque)
	
	novo_decalque.global_position = ponto
	_alinhar_decalque(novo_decalque, normal)

func _alinhar_decalque(decal, normal):
	decal.global_rotation = Vector3.ZERO 
	
	if normal.is_equal_approx(Vector3.UP):
		decal.rotation_degrees.x = 0
	elif normal.is_equal_approx(Vector3.DOWN):
		decal.rotation_degrees.x = 180
	else:
		decal.look_at(decal.global_position - normal, Vector3.UP)
		decal.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))


func _on_jogo_carimbar_mudou_encomenda(encomenda: Encomenda) -> void:
	if encomenda is Pacote and encomenda.item_res.cabe_em != ItemResource.TamanhoPacote.PEQUENO:
		ehCaixa = true
		decal_size = Vector3(0.5, 0.06, 0.5)
	elif encomenda is Pacote and encomenda.item_res.cabe_em == ItemResource.TamanhoPacote.PEQUENO:
		ehCaixa = false
		decal_size = Vector3(0.4, 0.04, 0.4)
	else:
		ehCaixa = false
		decal_size = Vector3(0.5, 0.04, 0.5)
