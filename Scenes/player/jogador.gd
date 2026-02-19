extends CharacterBody3D

@export_group("Velocidade")
@export var velocidade: float = 5.0
@export var pulo: float = 3.0
@export var queda: float = 9.0

@export_group("Visão câmera")
@export var camera: Camera3D
@export var pivot_camera: Node3D
@export var sensibilidade: float = 0.3
@export var visao_min_angle: float = -60
@export var visao_max_angle: float = 60

@export_group("Raycast")
@export var distancia_max_cast: float = 2
var ultimo_raycast_achado: CollisionObject3D
var interagivel_atual: Interagivel


var dir: Vector3
var target_velocity: Vector3
var look_rot: Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	_handle_movimento(delta)
	_handle_raycast(delta)
	
func _handle_raycast(_delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var espaco = get_world_3d().direct_space_state
	
	var origem = camera.project_ray_origin(mouse)
	var destino = origem + camera.project_ray_normal(mouse) * distancia_max_cast
	
	var query = PhysicsRayQueryParameters3D.create(origem, destino)
	query.collide_with_areas = false
	query.exclude = [self]
	
	var res = espaco.intersect_ray(query)
	var col: CollisionObject3D = null
	
	if not res.is_empty() and origem.distance_to(res.position) <= distancia_max_cast:
		col = res.collider
	
	if ultimo_raycast_achado != null and ultimo_raycast_achado != col:
		ultimo_raycast_achado.mouse_exited.emit()
		
	if col == null:
		ultimo_raycast_achado = null
		interagivel_atual = null
	elif ultimo_raycast_achado != col:
		ultimo_raycast_achado = col
		ultimo_raycast_achado.mouse_entered.emit()
		
		var interagiveis = ultimo_raycast_achado.find_children("*", "Interagivel", false)
		interagivel_atual = null if len(interagiveis) == 0 else interagiveis[0]
	

func _handle_movimento(delta: float) -> void:
	pivot_camera.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y
	
	dir = Vector3.ZERO
	dir.x = Input.get_axis("esquerda", "direita")
	dir.z = Input.get_axis("cima", "baixo")
	
	if dir != Vector3.ZERO:
		dir = dir.normalized()
	
	var up_vector = global_transform.basis.y
	
	dir = dir.rotated(up_vector, rotation.y)
	
	target_velocity.x = dir.x * velocidade
	target_velocity.z = dir.z * velocidade
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (queda * delta)
	
	velocity = target_velocity
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pulo") and is_on_floor():
		target_velocity.y = pulo
		
	if event is InputEventMouseMotion:
		look_rot.y -= event.relative.x * sensibilidade
		look_rot.x -= event.relative.y * sensibilidade
		look_rot.x = clamp(look_rot.x, visao_min_angle, visao_max_angle)
	
	if event is InputEventMouseButton:
		if interagivel_atual != null and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			interagivel_atual.interagir()
		
