class_name Rotacionavel
extends Node

@export var alvo: Node3D

@export var direcao_arr: Array[Singleton.Direcao] = [Singleton.Direcao.FRENTE,Singleton.Direcao.DIREITA,Singleton.Direcao.COSTAS,Singleton.Direcao.ESQUERDA,Singleton.Direcao.FRENTE]
@export var direcao = [0, PI/2, PI, 1.5*PI, deg_to_rad(360)]
@export var offset_rot_deg = 90

@export_group("Axis horizontal")
@export var rot_x_x := false
@export var rot_x_y := true
@export var rot_x_z := false

@export_group("Axis vertical")
@export var rotaciona_na_vertical := false
@export var pode_rot_cima := true
@export var pode_rot_baixo := false

var rot_vertical := 0

var dir_atual = 0
var girando := false

signal giro_vertical_mudou(dir: float)

signal comecou_girar(direcao: Singleton.Direcao, antiga_direcao: Singleton.Direcao)
signal terminou_girar(direcao: Singleton.Direcao)

func get_direcao_atual() -> Singleton.Direcao:
	return direcao_arr[dir_atual]

func girar(dir: int) -> void:
	if girando:
		return
	
	var antiga_dir = dir_atual
	var nova_rotacao = alvo.rotation
	dir_atual = dir_atual + dir
	
	if dir_atual >= len(direcao):
		alvo.rotation = set_rot_horizontal(alvo.rotation, 0)
		dir_atual = 1
	elif dir_atual < 0:
		dir_atual = len(direcao) - 2
		alvo.rotation = set_rot_horizontal(alvo.rotation, direcao[len(direcao) - 1])
	
	nova_rotacao = add_rot_horizontal(alvo.rotation, deg_to_rad(offset_rot_deg * dir))

	girando = true
	var tween = get_tree().create_tween()
	tween.tween_property(alvo, "rotation", nova_rotacao, 0.5)
	tween.finished.connect(fim_girar)
	
	comecou_girar.emit(direcao_arr[dir_atual], direcao_arr[antiga_dir])

func fim_girar() -> void:
	girando = false
	terminou_girar.emit(direcao_arr[dir_atual])

func set_rot_horizontal(vec: Vector3, val: float) -> Vector3:
	if rot_x_x:
		vec.x = val
	elif rot_x_y:
		vec.y = val
	elif rot_x_z:
		vec.z = val
	return vec

func add_rot_horizontal(vec: Vector3, val: float) -> Vector3:
	if rot_x_x:
		vec.x += val
	elif rot_x_y:
		vec.y += val
	elif rot_x_z:
		vec.z += val
	return vec

func set_rot_vertical(vec: Vector3, val: float) -> Vector3:
	if dir_atual == 0 or dir_atual == 4:
		vec.x = val
	elif dir_atual == 1:
		vec.z = val
	elif dir_atual == 2:
		vec.x = -val
	elif dir_atual == 3:
		vec.z = -val
	
	return vec


func girar_vertical(dir: int) -> void:
	if girando:
		return
	
	if dir == rot_vertical:
		return
	
	if not pode_rot_baixo and rot_vertical == 0 and dir < 0:
		return
	
	if not pode_rot_cima and rot_vertical == 0 and dir > 0:
		return
	
	var nova_rotacao = alvo.rotation
	rot_vertical += dir
	
	nova_rotacao = set_rot_vertical(alvo.rotation, deg_to_rad(90 * rot_vertical))

	girando = true
	var tween = get_tree().create_tween()
	tween.tween_property(alvo, "rotation", nova_rotacao, 0.5)
	tween.finished.connect(fim_girar)

	giro_vertical_mudou.emit(rot_vertical)
