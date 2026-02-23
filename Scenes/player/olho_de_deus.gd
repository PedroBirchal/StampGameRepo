extends Node3D

enum DirecaoQuarto { FRENTE, ESQUERDA, COSTAS, DIREITA }

@export_group("Raycast")
@export var distancia_max_cast: float = 5
@export var camera: Camera3D

@export_group("O Mundo")
@export var carimbo: Jogador
@export var direcao_grupo: Dictionary[DirecaoQuarto, String]
var direcao_quarto = [DirecaoQuarto.FRENTE,DirecaoQuarto.DIREITA,DirecaoQuarto.COSTAS,DirecaoQuarto.ESQUERDA,DirecaoQuarto.FRENTE]
var grupo_para_excluir : Array


var ultimo_raycast_achado: CollisionObject3D
var interagivel_atual: Interagivel

var direcao = [0, PI/2, PI, 1.5*PI, deg_to_rad(360)]
var dir_atual = 0
var girando := false

var pos_raycast : Vector3


func _ready() -> void:
	var nodes = get_tree().get_nodes_in_group(direcao_grupo[direcao_quarto[dir_atual]])
	grupo_para_excluir = nodes.map(func(node): return node.get_rid())

func girar(dir: int) -> void:
	if girando:
		return
	
	var nova_rotacao = rotation
	dir_atual = dir_atual + dir
	
	if dir_atual >= len(direcao):
		rotation.y = 0
		dir_atual = 1
	elif dir_atual < 0:
		dir_atual = len(direcao) - 2
		rotation.y = direcao[len(direcao) - 1]
	
	nova_rotacao.y = direcao[dir_atual]

	girando = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", nova_rotacao, 0.5)
	tween.finished.connect(fim_girar)
	
	var nodes = get_tree().get_nodes_in_group(direcao_grupo[direcao_quarto[dir_atual]])
	grupo_para_excluir = nodes.map(func(node): return node.get_rid())

func fim_girar() -> void:
	girando = false
	
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		raycastar()
		if interagivel_atual != null and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			if interagivel_atual.setar_area_pos_click:
				interagivel_atual.setar_area_click(pos_raycast)
			
			carimbo.interagir_com(interagivel_atual)
