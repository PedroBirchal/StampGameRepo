extends Node3D

@export_group("Raycast")
@export var distancia_max_cast: float = 5
@export var camera: Camera3D

@export_group("O Mundo")
@export var rotacionavel: Rotacionavel
@export var carimbo: Jogador
var grupo_para_excluir : Array


var ultimo_raycast_achado: CollisionObject3D
var interagivel_atual: Interagivel
var pos_raycast : Vector3


func _ready() -> void:
	_on_rotacionavel_comecou_girar(rotacionavel.get_direcao_atual(), -1)
	
	carimbo.on_chegou.connect(func(interagivel: Interagivel): interagivel.interagir())

	
func raycastar() -> void:
	var mouse = get_viewport().get_mouse_position()
	var espaco = get_world_3d().direct_space_state
	
	var origem = camera.project_ray_origin(mouse)
	var destino = origem + camera.project_ray_normal(mouse) * distancia_max_cast
	
	var query = PhysicsRayQueryParameters3D.create(origem, destino)
	query.collide_with_areas = false
	
	var arr = [self]
	arr.append_array(grupo_para_excluir)
	query.exclude = arr
	
	var res = espaco.intersect_ray(query)
	var col: CollisionObject3D = null
	
	if res.has("position"):
		pos_raycast = res.position
	
	if not res.is_empty() and origem.distance_to(res.position) <= distancia_max_cast:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		col = res.collider
	
	if ultimo_raycast_achado != null and ultimo_raycast_achado != col:
		ultimo_raycast_achado.mouse_exited.emit()
		
	if col == null:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		ultimo_raycast_achado = null
		interagivel_atual = null
	elif ultimo_raycast_achado != col:
		ultimo_raycast_achado = col
		ultimo_raycast_achado.mouse_entered.emit()
		
		var interagiveis = ultimo_raycast_achado.find_children("*", "Interagivel", false)
		interagivel_atual = null if len(interagiveis) == 0 else interagiveis[0]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		raycastar()
		if interagivel_atual != null and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			if interagivel_atual.setar_area_pos_click:
				interagivel_atual.setar_area_click(pos_raycast)
			
			carimbo.interagir_com(interagivel_atual)


func _on_rotacionavel_comecou_girar(direcao: int, dir_antiga: int) -> void:
	var nodes = get_tree().get_nodes_in_group(Singleton.direcao_grupo[rotacionavel.get_direcao_atual()])
	
	grupo_para_excluir = nodes.filter(func(node): return node is CollisionObject3D).map(func(node): return node.get_rid())
	var meshs = nodes.filter(func(node): return node is MeshInstance3D)
	for mesh in meshs:
		var mat: BaseMaterial3D = mesh.get_active_material(0)
		var albedo = mat.albedo_color
		
		if albedo.a == 0.0:
			continue
			
		albedo.a = 0.0
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(mat, "albedo_color", albedo, 0.4)
	
	if dir_antiga == direcao or dir_antiga < 0:
		return
	
	var nodes_antigos = get_tree().get_nodes_in_group(Singleton.direcao_grupo[dir_antiga])
	var meshs_antigas = nodes_antigos.filter(func(node): return node is MeshInstance3D)
	
	for mesh in meshs_antigas:
		var mat: BaseMaterial3D = mesh.get_active_material(0)
		
		var albedo = mat.albedo_color
		if albedo.a == 1:
			continue
			
		albedo.a = 1.0
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(mat, "albedo_color", albedo, 0.2)
	


func _on_rotacionavel_terminou_girar(direcao: int) -> void:
	pass # Replace with function body.
