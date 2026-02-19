class_name Jogador
extends CharacterBody3D

signal on_chegou(interagivel)

@onready var agent := $NavigationAgent3D
var interagivel : Interagivel
var target_pos: Vector3

@export var animacao : AnimationPlayer

@export_group("Movimento")
@export var velocidade := 2.5
@export var giro := 3


func _physics_process(delta: float) -> void:
	if interagivel != null:
		agent.target_position = target_pos
		var dir = global_position.direction_to(agent.get_next_path_position())
		velocity = dir * velocidade
		
		if agent.is_navigation_finished():
			print("CHEGUEEIII")
			on_chegou.emit(interagivel)
			interagivel = null
			velocity = Vector3.ZERO
		
		var giro_speed = giro
		var rotacao = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
		if abs(rotacao - rotation.y) > deg_to_rad(40):
			giro_speed *= 2
			
		rotation.y = move_toward(rotation.y, rotacao, delta * giro_speed)
	
	move_and_slide()

func interagir_com(interagivel: Interagivel) -> void:
	self.interagivel = interagivel
	target_pos = interagivel.area_de_interacao.global_position
	
	var dir = global_position.direction_to(target_pos)
	rotation.y = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
	
	animacao.play(&"Armature_Passaro|Walking")
