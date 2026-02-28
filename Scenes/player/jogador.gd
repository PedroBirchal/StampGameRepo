class_name Jogador
extends CharacterBody3D

signal on_chegou(interagivel)

@onready var agent := $NavigationAgent3D
var interagivel : Interagivel
var target_pos: Vector3

@export var animacao : AnimationPlayer
@export var animacaoState : AnimationTree
@export var is_walking = false # Para animação

@export_group("Movimento")
@export var velocidade := 2.5
@export var giro := 5


func _physics_process(delta: float) -> void:
	if interagivel != null:
		agent.target_position = target_pos
		var dir = global_position.direction_to(agent.get_next_path_position())
		velocity = dir * velocidade
		
		if agent.is_navigation_finished():
			_ao_acabar()
			return
		
		var giro_speed = giro
		var rotacao = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
		if abs(rotacao - rotation.y) > deg_to_rad(40):
			giro_speed *= 2
			
		rotation.y = move_toward(rotation.y, rotacao, delta * giro_speed)
	
	move_and_slide()

func interagir_com(interag: Interagivel) -> void:
	if Jogo.instance.estado != Jogo.Estado.QUARTO:
		return
	
	self.interagivel = interag
	target_pos = interag.area_de_interacao.global_position
	
	agent.target_position = target_pos
	if agent.is_target_reached():
		_ao_acabar()
		return
	
	var dir = global_position.direction_to(target_pos)
	rotation.y = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
	
	is_walking = true

func _ao_acabar() -> void:
	on_chegou.emit(interagivel)
	interagivel = null
	velocity = Vector3.ZERO
	is_walking = false
	
